typealias ListResults = (results: [DatabaseObject], totalPages: Int, totalResults: Int)

extension Client {
    
    /// Loads a list of movies for particulas request
    ///
    /// - Parameters:
    ///   - requestType: type of request, which conforms ListRequest protocol
    ///   - page: page number
    ///   - completion: completion handler, which contains a tuple, that consists of an array of DatabaseObject structures, total pages quantity and total results quantity, if success or a tuple, that consists of an empty array and zeros, if failed
    func loadList(of requestType: ListRequest, onPage page: Int, completion: @escaping (Result<ListResults>)->Void) {
        switch requestType.rawValue.type {
        case .movieGenres:
            loadMoviesListWithGenreId(requestType.rawValue.path, onPage: page, completion: completion)
        
        case .moviesCategories:
            loadMoviesCategoriesList(path: requestType.rawValue.path, onPage: page, completion: completion)
        
        case .search:
            let requestType = requestType as! SearchListRequest
            loadSearchResultsList(forKey: requestType.keyword, path: requestType.rawValue.path, mediaType: requestType.mediaType, onPage: page, completion: completion)
        
        case .similar:
            loadSimilarMoviesList(path: requestType.rawValue.path, mediaType: requestType.mediaType, onPage: page, completion: completion)
        }
    }
    
    private func loadMoviesCategoriesList(path: String, onPage page: Int, completion: @escaping (Result<ListResults>)->Void) {
        
        let params = ["page" : page]
        
        request(path: path, params: params).responseJSON { (response) in
            
            var results = [DatabaseObject]()
            
            guard let json = response.result.value as? [String: Any],
                let totalResults = json["total_results"] as? Int,
                let totalPages = json["total_pages"] as? Int,
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    completion(.error)
                    return
            }
            
            results = dictionary.compactMap { DatabaseObject(ofType: .movie, fromJson: $0) }
            completion(.success((results: results, totalPages: totalPages, totalResults: totalResults)))
        }
    }
    
    private func loadSimilarMoviesList(path: String, mediaType: MediaType, onPage page: Int, completion: @escaping (Result<ListResults>)->Void) {
        
        let params = [ "page" : page ]
    
        request(path: path, params: params).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let totalResults = json["total_results"] as? Int,
                let totalPages = json["total_pages"] as? Int,
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    completion(.error)
                    return
            }
            
            let similar = dictionary.compactMap { DatabaseObject(ofType: mediaType, fromJson: $0) }
            completion(.success((results: similar, totalPages: totalPages, totalResults: totalResults)))
        }
    }
    
    private func loadSearchResultsList(forKey key: String, path: String, mediaType: MediaType, onPage page: Int, completion: @escaping (Result<ListResults>)->Void) {
        
        let params: [String:Any] = [
            "query" : key,
            "page" : page,
            "include_adult" : "false"
        ]
        request(path: path, params: params).responseJSON { (response) in

            guard let json = response.result.value as? [String: Any],
                let totalResults = json["total_results"] as? Int,
                let totalPages = json["total_pages"] as? Int,
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    completion(.error)
                    return
            }

            let results = dictionary.compactMap { DatabaseObject(ofType: mediaType, fromJson: $0) }
            completion(.success((results: results, totalPages: totalPages, totalResults: totalResults)))
        }
    }
    
    private func loadMoviesListWithGenreId(_ genreId: String, onPage page: Int, completion: @escaping (Result<ListResults>)->Void) {
        
        let params: [String:Any] = [
            "sort_by" : "popularity.desc",
            "include_adult" : false,
            "page" : page,
            "with_genres" : genreId
        ]
        
        request(path: "/discover/movie", params: params).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let totalResults = json["total_results"] as? Int,
                let totalPages = json["total_pages"] as? Int,
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    completion(.error)
                    return
            }
            
            let results = dictionary.compactMap { DatabaseObject(ofType: .movie, fromJson: $0) }
            completion(.success((results: results, totalPages: totalPages, totalResults: totalResults)))
        }
    }
    
}
