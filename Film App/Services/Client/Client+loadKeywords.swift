extension Client {
    
    /// Loads list of keywords, according to user's text
    ///
    /// - Parameters:
    ///   - key: user's text
    ///   - completion: completion handler, which contains array of keywords if success or empty array if failed or had no results
    func loadKeywords(key: String, completion: @escaping ([String])->Void) {
        request(path: "/search/keyword", params: [
            "query": key,
            "page": 1
            ]).responseJSON { (response) in
                guard let json = response.result.value as? [String: Any],
                    let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                        completion([])
                        return
                }
                
                let keywords = dictionary.map {
                    $0["name"] as! String
                }
                
                completion(keywords)
        }
    }
    
}
