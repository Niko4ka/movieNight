enum MoviesCategory: String {
    case nowPlaying = "/movie/now_playing"
    case popular = "/movie/popular"
    case upcoming = "/movie/upcoming"
}

extension Client {
    
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
            var results = dictionary.compactMap { DatabaseObject(ofType: .movie, fromJson: $0) }
            completion(results)            
        }
    }
    
}
