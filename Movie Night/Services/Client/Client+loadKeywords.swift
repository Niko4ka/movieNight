extension Client {
    
    /// Loads list of keywords, according to user's text
    ///
    /// - Parameters:
    ///   - key: user's text
    ///   - completion: completion handler, which contains array of keywords if success or empty array if failed or had no results
    func loadKeywords(key: String, completion: @escaping (Result<[String]>)->Void) {
        
        let params: [String : Any] = [
            "query": key,
            "page": 1
            ]
        
        request(path: "/search/keyword", params: params).responseJSON { (response) in
                guard let json = response.result.value as? [String: Any],
                    let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                        completion(.error)
                        return
                }
                
                let keywords = dictionary.map { $0["name"] as! String }
                completion(.success(keywords))
        }
    }
    
}
