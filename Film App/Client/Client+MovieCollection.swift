import Foundation

extension Client {
    
    func loadMovieCollection(collectionId id: Int, completion: @escaping ((cover: String?, parts: [DatabaseObject])?)->Void) {
        
        var cover: String?
        
        request(path: "/collection/\(id)").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let dictionary = json["parts"] as? [Dictionary<String, Any>] else {
                    completion(nil)
                    return
            }
            
            if let coverPath = json["poster_path"] as? String {
                cover = coverPath
            }
            
            let parts = dictionary.compactMap { DatabaseObject(ofType: .movie, fromJson: $0) }
            let result = (cover: cover, parts: parts)
            
            
            completion(result)
        }
        
    }
    
}
