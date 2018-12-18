//
//  MovieTrailer.swift
//  Film App
//
//  Created by Вероника Данилова on 18/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.

import Foundation

struct MovieTrailer {
    var title: String
    var id: String
//    var url: URL
    var duration: String
    var thumbnailUrl: URL

    init?(from json: [String: Any]) {
        
        guard let trailerId = json["id"] as? String,
            let videoUrl = URL(string: "https://www.youtube.com/watch?v=\(trailerId)") else { return nil }
        
        self.id = trailerId
//        self.url = videoUrl
        
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
