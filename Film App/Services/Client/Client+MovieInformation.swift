import Foundation
import Alamofire

extension Client {
    
    /// Loads information about particular movie
    ///
    /// - Parameters:
    ///   - id: movie or TV Show id
    ///   - type: mediatype(.movie or .tvShow)
    ///   - completion: completion handler, which contains MovieDetails if success or nil if failed
    func loadMovieDetails(forId id: Int, andType type: MediaType, completion: @escaping (MovieDetails?)->Void) {
        
        var path: String = ""
        if type == .movie {
            path = "/movie/\(id)"
        } else {
            path = "/tv/\(id)"
        }
        
        request(path: path, params: [:]).responseJSON { (response) in
            guard let json = response.result.value as? [String: Any],
                let details = MovieDetails(ofType: type, from: json) else {
                    completion(nil)
                    return
            }
            
            completion(details)
        }
    }
    
    /// Loads information about movie cast (actors, director, writer, producers)
    ///
    /// - Parameters:
    ///   - id: movie or TV Show id
    ///   - type: mediatype(.movie or .tvShow)
    ///   - completion: completion handler, which contains MovieCast if success or nil if failed
    func loadMovieCast(forId id: Int, andType type: MediaType, completion: @escaping (MovieCast?)->Void) {
        
        var path: String = ""
        if type == .movie {
            path = "/movie/\(id)/credits"
        } else {
            path = "/tv/\(id)/credits"
        }
        
        request(path: path, params: [:]).responseJSON { (response) in
            guard let json = response.result.value as? [String: Any],
                let cast = MovieCast(ofType: type, from: json) else {
                    completion(nil)
                    return
            }
            
            completion(cast)
        }
        
    }
    
    /// Loads movie trailers from Youtube
    ///
    /// - Parameters:
    ///   - id: movie or TV Show id
    ///   - type: mediatype(.movie or .tvShow)
    ///   - completion: completion handler, which contains an array of MovieTrailer structures if success or an empty array if failed
    func loadMovieTrailers(forId id: Int, andType type: MediaType, completion: @escaping ([MovieTrailer])->Void) {
        
        var trailers = [MovieTrailer]()
        var path: String = ""
        if type == .movie {
            path = "/movie/\(id)/videos"
        } else {
            path = "/tv/\(id)/videos"
        }
        
        request(path: path, params: [:]).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let results = json["results"] as? [Dictionary<String, Any>] else {
                    completion(trailers)
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
                completion(trailers)
            }
        }
        
    }
    
    /// Loads movie reviews
    ///
    /// - Parameters:
    ///   - id: movie or TV Show id
    ///   - type: mediatype(.movie or .tvShow)
    ///   - completion: completion handler, which contains an array of MovieReview structures if success or an empty array if failed
    func loadMovieReviews(forId id: Int, andType type: MediaType, completion: @escaping ([MovieReview])->Void) {
        
        var reviews = [MovieReview]()
        var path: String = ""
        if type == .movie {
            path = "/movie/\(id)/reviews"
        } else {
            path = "/tv/\(id)/reviews"
        }
        
        request(path: path, params: [:]).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let results = json["results"] as? [Dictionary<String, Any>] else {
                    completion(reviews)
                    return
            }
            
            if !results.isEmpty {
                for result in results {
                    if let review = MovieReview(from: result) {
                        reviews.append(review)
                    }
                }
                completion(reviews)
            }
        }
        
    }
    
    /// Loads similar movies
    ///
    /// - Parameters:
    ///   - id: movie or TV Show id
    ///   - type: mediatype(.movie or .tvShow)
    ///   - completion: completion handler, which contains an array of DatabaseObject structures if success or an empty array if failed
    func loadSimilarMovies(forId id: Int, andType type: MediaType, completion: @escaping ([DatabaseObject])->Void) {
        
        var similar = [DatabaseObject]()
        var path: String = ""
        if type == .movie {
            path = "/movie/\(id)/similar"
        } else {
            path = "/tv/\(id)/similar"
        }
        
        request(path: path, params: [:]).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let results = json["results"] as? [Dictionary<String, Any>] else {
                    completion(similar)
                    return
            }
            
            for result in results {
                if let item = DatabaseObject(ofType: type, fromJson: result) {
                    similar.append(item)
                }
            }
            
            completion(similar)
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
