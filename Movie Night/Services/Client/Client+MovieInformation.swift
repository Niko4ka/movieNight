import Foundation
import Alamofire

extension Client {
    
    /// Loads information about particular movie
    ///
    /// - Parameters:
    ///   - id: movie or TV Show id
    ///   - type: mediatype(.movie or .tvShow)
    ///   - completion: completion handler, which contains MovieDetails if success or error if failed
    func loadMovieDetails(forId id: Int, andType type: MediaType, completion: @escaping (Result<MovieDetails>)->Void) {
        
        let path = type == .movie ? "/movie/\(id)" : "/tv/\(id)"
        
        request(path: path, params: [:]).responseJSON { (response) in
            guard let json = response.result.value as? [String: Any],
                let details = MovieDetails(ofType: type, from: json) else {
                    completion(.error)
                    return
            }
            completion(.success(details))
        }
    }
    
    /// Loads information about movie cast (actors, director, writer, producers)
    ///
    /// - Parameters:
    ///   - id: movie or TV Show id
    ///   - type: mediatype(.movie or .tvShow)
    ///   - completion: completion handler, which contains MovieCast if success or error if failed
    func loadMovieCast(forId id: Int, andType type: MediaType, completion: @escaping (Result<MovieCast>)->Void) {
        
        let path: String = type == .movie ? "/movie/\(id)/credits" : "/tv/\(id)/credits"
        
        request(path: path, params: [:]).responseJSON { (response) in
            guard let json = response.result.value as? [String: Any],
                let cast = MovieCast(ofType: type, from: json) else {
                    completion(.error)
                    return
            }
            completion(.success(cast))
        }
    }
    
    /// Loads movie trailers from Youtube
    ///
    /// - Parameters:
    ///   - id: movie or TV Show id
    ///   - type: mediatype(.movie or .tvShow)
    ///   - completion: completion handler, which contains an array of MovieTrailers if success or error if failed
    func loadMovieTrailers(forId id: Int, andType type: MediaType, completion: @escaping (Result<[MovieTrailer]>)->Void) {
        
        var trailers = [MovieTrailer]()
        let path = type == .movie ? "/movie/\(id)/videos" : "/tv/\(id)/videos"
        
        request(path: path, params: [:]).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let results = json["results"] as? [Dictionary<String, Any>] else {
                    completion(.error)
                    return
            }
            
            let trailersLoadingGroup = DispatchGroup()
            
            for video in results {
                trailersLoadingGroup.enter()
                if let youtubeId = video["key"] as? String {
                    self.loadYoutubeVideo(withId: youtubeId, completion: { (trailer) in
                        if let trailer = trailer {
                            trailers.append(trailer)
                        }
                        trailersLoadingGroup.leave()
                    })
                } else {
                    trailersLoadingGroup.leave()
                }
            }
            
            trailersLoadingGroup.notify(queue: .main) {
                completion(.success(trailers))
            }
        }
    }
    
    /// Loads movie reviews
    ///
    /// - Parameters:
    ///   - id: movie or TV Show id
    ///   - type: mediatype(.movie or .tvShow)
    ///   - completion: completion handler, which contains an array of MovieReviews if success or error if failed
    func loadMovieReviews(forId id: Int, andType type: MediaType, completion: @escaping (Result<[MovieReview]>)->Void) {
        
        let path = type == .movie ? "/movie/\(id)/reviews" : "/tv/\(id)/reviews"
        
        request(path: path, params: [:]).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let results = json["results"] as? [Dictionary<String, Any>] else {
                    completion(.error)
                    return
            }
            
            let reviews = results.compactMap { MovieReview(from: $0) }
            completion(.success(reviews))
        }
    }
    
    /// Loads similar movies
    ///
    /// - Parameters:
    ///   - id: movie or TV Show id
    ///   - type: mediatype(.movie or .tvShow)
    ///   - completion: completion handler, which contains an array of DatabaseObjects  if success or error if failed
    func loadSimilarMovies(forId id: Int, andType type: MediaType, completion: @escaping (Result<[DatabaseObject]>)->Void) {

        let path = type == .movie ? "/movie/\(id)/similar" : "/tv/\(id)/similar"
        
        request(path: path, params: [:]).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let results = json["results"] as? [Dictionary<String, Any>] else {
                    completion(.error)
                    return
            }
            
            let similar = results.compactMap { DatabaseObject(ofType: type, fromJson: $0) }
            completion(.success(similar))
        }
    }
    

    // Private
    
    private func loadYoutubeVideo(withId youtubeId: String, completion: @escaping (MovieTrailer?)->Void) {
        
        var trailer: MovieTrailer?
        let path = "https://www.googleapis.com/youtube/v3/videos"
        let params: [String : Any] = [
            "part" : "snippet,contentDetails",
            "id" : youtubeId,
            "key" : googleKey
        ]
        
        AF.request(path, parameters: params).responseJSON { (response) in
            if let json = response.result.value as? [String: Any],
                let items = json["items"] as? [[String: Any]] {
                
                if !items.isEmpty {
                    if let movieTrailer = MovieTrailer(from: items[0]) {
                        trailer = movieTrailer
                    }
                }
                completion(trailer)
            }
        }
    }

}
