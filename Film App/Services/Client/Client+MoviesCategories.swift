/// Enum, which contains movie categories titles and their request paths, as raw value
///
/// - nowPlaying: movies, that are playing in cinemas now
/// - popular: popular movies
/// - upcoming: movies, that will be playing in cinemas soon
enum MoviesCategory: String {
    case nowPlaying = "/movie/now_playing"
    case popular = "/movie/popular"
    case upcoming = "/movie/upcoming"
}

extension Client {
    
    /// Loads movies of particular category (popular, upcoming, etc.)
    ///
    /// - Parameters:
    ///   - category: MoviesCategoty case
    ///   - completion: completion handler, which contains an array of DatabaseObject structures if success or an empty array if failed
    func loadMoviesCategory(_ category: MoviesCategory, completion: @escaping ([DatabaseObject])->Void) {
        
        let params: [String:Any] = [
            "page" : 1,
            "region" : "RU"
        ]

        request(path: category.rawValue, params: params).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    let results = [DatabaseObject]()
                    completion(results)
                    return
            }
            let results = dictionary.compactMap { DatabaseObject(ofType: .movie, fromJson: $0) }
            completion(results)            
        }
    }
    
}
