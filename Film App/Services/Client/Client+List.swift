extension Client {
    
    func loadList(of requestType: ListRequest, onPage page: Int, completion: @escaping ([DatabaseObject], Int, Int)->Void) {
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
    
    private func loadMoviesCategoriesList(path: String, onPage page: Int, completion: @escaping ([DatabaseObject], Int, Int)->Void) {
        
        let params = [ "page" : page]
        
        request(path: path, params: params).responseJSON { (response) in
            
            var results = [DatabaseObject]()
            
            guard let json = response.result.value as? [String: Any],
                let totalResults = json["total_results"] as? Int,
                let totalPages = json["total_pages"] as? Int,
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    completion(results, 0, 0)
                    return
            }
            
            results = dictionary.compactMap { DatabaseObject(ofType: .movie, fromJson: $0) }
            completion(results, totalPages, totalResults)
        }
    }
    
    private func loadSimilarMoviesList(path: String, mediaType: MediaType, onPage page: Int, completion: @escaping ([DatabaseObject], Int, Int)->Void) {
        
        var similar = [DatabaseObject]()
        let params = [ "page" : page ]
    
        request(path: path, params: params).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let totalResults = json["total_results"] as? Int,
                let totalPages = json["total_pages"] as? Int,
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    completion(similar, 0, 0)
                    return
            }
            
            similar = dictionary.compactMap { DatabaseObject(ofType: mediaType, fromJson: $0) }
            completion(similar, totalPages, totalResults)
        }
        
    }
    
    private func loadSearchResultsList(forKey key: String, path: String, mediaType: MediaType, onPage page: Int, completion: @escaping ([DatabaseObject], Int, Int)->Void) {
        
        let params: [String:Any] = [
            "query" : key,
            "page" : page,
            "include_adult" : "false"
        ]
        request(path: path, params: params).responseJSON { (response) in
            
            var results = [DatabaseObject]()
            
            guard let json = response.result.value as? [String: Any],
                let totalResults = json["total_results"] as? Int,
                let totalPages = json["total_pages"] as? Int,
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    completion(results, 0, 0)
                    return
            }

            results = dictionary.compactMap { DatabaseObject(ofType: mediaType, fromJson: $0) }
            completion(results, totalPages, totalResults)
        }
    }
    
    private func loadMoviesListWithGenreId(_ genreId: String, onPage page: Int, completion: @escaping ([DatabaseObject], Int, Int)->Void) {
        
        let params: [String:Any] = [
            "sort_by" : "popularity.desc",
            "include_adult" : false,
            "page" : page,
            "with_genres" : genreId
        ]
        
        request(path: "/discover/movie", params: params).responseJSON { (response) in
            
            var results = [DatabaseObject]()
            
            guard let json = response.result.value as? [String: Any],
                let totalResults = json["total_results"] as? Int,
                let totalPages = json["total_pages"] as? Int,
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    completion(results, 0, 0)
                    return
            }
            
            results = dictionary.compactMap { DatabaseObject(ofType: .movie, fromJson: $0) }
            completion(results, totalPages, totalResults)
            
        }
        
    }
    
}
