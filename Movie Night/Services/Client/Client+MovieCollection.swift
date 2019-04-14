import Foundation

typealias CollectionInfo = (cover: String?, parts: [DatabaseObject])

extension Client {
    
    /// Loads particular movie collection
    ///
    /// - Parameters:
    ///   - id: collection id
    ///   - completion: completion handler, which contains CollectionInfo if success or error if failed
    func loadMovieCollection(collectionId id: Int, completion: @escaping (Result<CollectionInfo>)->Void) {
        
        request(path: "/collection/\(id)").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let dictionary = json["parts"] as? [Dictionary<String, Any>] else {
                    completion(.error)
                    return
            }
            let cover = json["poster_path"] as? String
            let parts = dictionary.compactMap { DatabaseObject(ofType: .movie, fromJson: $0) }
            let result = (cover: cover, parts: parts)
            completion(.success(result))
        }
    }
    
}
