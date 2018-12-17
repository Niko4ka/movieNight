//
//  DatabaseObject.swift
//  Film App
//
//  Created by Вероника Данилова on 11/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import Foundation

struct DatabaseObject {
    
//    enum MediaTypes: String {
//        case movie = "movie"
//        case tv = "tv"
//    }
    
    var mediaType: MediaType
    var image: String
    var genres: String = ""
    var title: String
    var id: Int

    
    init?(fromJson json: [String: Any]) {
        
        guard let mediaType = json["media_type"] as? String,
            let id = json["id"] as? Int else {
                return nil
        }
        
        if let posterImage = json["poster_path"] as? String {
            self.image = posterImage
        } else {
            guard let personImage = json["profile_path"] as? String else { return nil }
            self.image = personImage
        }
        
        if let title = json["title"] as? String {
            self.title = title
        } else {
            guard let name = json["name"] as? String else { return nil }
            self.title = name
        }
        
        if let genreIds = json["genre_ids"] as? Array<Int> {

            for i in 0..<genreIds.count {

                switch mediaType {
                case "movie":
                    
                    if let genre = ConfigurationService.shared.moviesGenres[genreIds[i]] {
                        if self.genres.isEmpty {
                            self.genres.append(genre)
                        } else {
                            self.genres.append(", " + genre)
                        }
                    }
                case "tv":
                    
                    if let genre = ConfigurationService.shared.tvGenres[genreIds[i]] {
                        if self.genres.isEmpty {
                            self.genres.append(genre)
                        } else {
                            self.genres.append(", " + genre)
                        }
                    }
                    
                default:
                    break
                }
            }
        }
        
        switch mediaType {
        case "movie":
            self.mediaType = MediaType.movie
        case "tv":
            self.mediaType = MediaType.tvShow
        case "person":
            self.mediaType = MediaType.person
        default:
            return nil
        }
        
        self.id = id
    }
    
}
