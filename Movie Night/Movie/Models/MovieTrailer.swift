import Foundation

/// Data structure, that contains information about the movie trailer
struct MovieTrailer {
    var title: String
    var id: String
    var duration: String
    var thumbnailUrl: URL

    init?(from json: [String: Any]) {
        
        guard let trailerId = json["id"] as? String else { return nil }
        
        self.id = trailerId
        
        guard let snippet = json["snippet"] as? [String: Any],
            let trailerTitle = snippet["title"] as? String,
            let thumbnails = snippet["thumbnails"] as? [String: Any],
            let mediumThumbnail = thumbnails["medium"] as? [String: Any],
            let mediumThumbnailUrl = mediumThumbnail["url"] as? String,
            let imageUrl = URL(string: "\(mediumThumbnailUrl)") else { return nil }
        
        self.title = trailerTitle
        self.thumbnailUrl = imageUrl
        
        guard let contentDetails = json["contentDetails"] as? [String: Any],
            let duration = contentDetails["duration"] as? String else { return nil }

        self.duration = duration.getYoutubeFormattedDuration()
    }
    
}
