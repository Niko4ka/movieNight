enum ListRequest: String {
    case nowPlayingMovies = "/movie/now_playing"
    case popularMovies = "/movie/popular"
    case upcomingMovies = "/movie/upcoming"
}


extension Client {
    
    func loadList(of requestType: ListRequest, onPage page: Int? = nil, completion: @escaping ([DatabaseObject], Int, Int)->Void) {
        
        let params = [
            "page" : page ?? 1
            
        ]
        
        request(path: requestType.rawValue, params: params).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let totalResults = json["total_results"] as? Int,
                let totalPages = json["total_pages"] as? Int,
                let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                    let results = [DatabaseObject]()
                    completion(results, 0, 0)
                    return
            }
            
            let results = dictionary.compactMap { DatabaseObject(ofType: .movie, fromJson: $0) }
            completion(results, totalPages, totalResults)
        }
        
    }
    
}
