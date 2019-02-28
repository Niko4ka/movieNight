import Foundation

/// Data structure, that contains review author and content info
struct MovieReview {
    
    var author: String
    var content: String
    
    init?(from json: [String: Any]) {
        guard let name = json["author"] as? String,
            let text = json["content"] as? String else { return nil }
        
        self.author = name
        self.content = text
    }
}
