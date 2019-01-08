import Foundation
import Alamofire

extension Client {
    
    func loadMovieDetails(forId id: Int, andType type: MediaType, completion: @escaping (MovieDetails)->Void) {
        
        var path: String = ""
        if type == .movie {
            path = "/movie/\(id)"
        } else {
            path = "/tv/\(id)"
        }
        
        request(path: path, params: [:]).responseJSON { (response) in
            guard let json = response.result.value as? [String: Any],
                let details = MovieDetails(ofType: type, from: json) else { return }
            
            completion(details)
        }
    }
    
    func loadMovieCast(forId id: Int, andType type: MediaType, completion: @escaping (MovieCast)->Void) {
        
        var path: String = ""
        if type == .movie {
            path = "/movie/\(id)/credits"
        } else {
            path = "/tv/\(id)/credits"
        }
        
        request(path: path, params: [:]).responseJSON { (response) in
            guard let json = response.result.value as? [String: Any],
                let cast = MovieCast(ofType: type, from: json) else { return }
            
            completion(cast)
        }
        
    }
    
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
                let results = json["results"] as? [Dictionary<String, Any>] else { return }
            
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
                }
            }
            
            trailersLoadingGroup.notify(queue: .main) {
                completion(trailers)
            }
        }
        
    }
    
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
                let results = json["results"] as? [Dictionary<String, Any>] else { return }
            
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
                let results = json["results"] as? [Dictionary<String, Any>] else { return }
            
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
            "part" : "snippet%2CcontentDetails",
            "id" : youtubeId,
            "key" : ConfigurationService.googleKey
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
