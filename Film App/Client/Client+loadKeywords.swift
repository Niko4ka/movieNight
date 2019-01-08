extension Client {
    
    func loadKeyWords(key: String, completion: @escaping ([String])->Void) {
        request(path: "/search/keyword", params: [
            "query": key,
            "page": 1
            ]).responseJSON { (response) in
                guard let json = response.result.value as? [String: Any],
                    let dictionary = json["results"] as? [Dictionary<String, Any>] else {
                        return
                }
                
                let keywords = dictionary.map {
                    $0["name"] as! String
                }
                
                completion(keywords)
        }
    }
    
}
