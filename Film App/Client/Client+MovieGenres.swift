extension Client {
    
    func loadMoviesWithGenre(_ genreId: Int, completion: @escaping ([DatabaseObject])->Void) {
        
        let params: [String:Any] = [
            "sort_by" : "popularity.desc",
            "include_adult" : false,
            "page" : 1,
            "with_genres" : genreId
        ]
        
        request(path: "/discover/movie", params: params).responseJSON { (response) in
            
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