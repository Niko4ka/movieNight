struct SearchResults {
    var movies: [DatabaseObject] = []
    var tvShows: [DatabaseObject] = []
    var persons: [DatabaseObject] = []
}

extension Client {

    /// Loads all mediatype's items, that suits the selected keyword
    ///
    /// - Parameters:
    ///   - key: selected keyword
    ///   - completion: completion handler, which contains SearchResults structure with minimum one non-empty array if success or SearchResults structure with all empty arrays if failed or had no results
    func loadSearchResults(forKey key: String, completion: @escaping (Result<SearchResults>)->Void) {
        
        let params: [String:Any] = [
            "language" : "en",
            "query" : key,
            "page" : 1,
            "include_adult" : "false"
        ]
        
        request(path: "/search/multi", params: params).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    completion(.error)
                    return
            }
            
            var results = SearchResults()
            let objects = dictionary.compactMap { DatabaseObject(fromJson: $0) }
            
            for object in objects {
                switch object.mediaType {
                case .movie:
                    results.movies.append(object)
                case .tvShow:
                    results.tvShows.append(object)
                case .person:
                    results.persons.append(object)
                }
            }

            completion(.success(results))
        }
    }
    
}
