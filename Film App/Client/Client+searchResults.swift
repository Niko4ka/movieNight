struct SearchResults {
    var movies: [DatabaseObject] = []
    var tvShows: [DatabaseObject] = []
    var persons: [DatabaseObject] = []
}

extension Client {
    
    func loadSearchResults(forKey key: String, completion: @escaping (SearchResults)->Void) {
        
        let params: [String:Any] = [
            "language" : "en",
            "query" : key,
            "page" : 1,
            "include_adult" : "false"
        ]
        request(path: "/search/multi", params: params).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    print(" --- 2 ---- error")
                    return
            }
            
            var results = SearchResults()
            
            let objects = dictionary.compactMap { DatabaseObject(fromJson: $0) }
            results.movies = objects.filter { $0.mediaType == .movie }
            results.tvShows = objects.filter { $0.mediaType == .tvShow }
            results.persons = objects.filter { $0.mediaType == .person }
            
            completion(results)
        }
    }
    
}
