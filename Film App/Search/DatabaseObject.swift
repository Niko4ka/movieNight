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
    
    var mediaType: String
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
                    
                    if let genre = Genres.shared.moviesGenres[genreIds[i]] {
                        if i == genreIds.count - 1 {
                            self.genres.append(genre)
                        } else {
                            let comma = ", "
                            self.genres.append(genre + comma)
                        }
                    }
                case "tv":
                    
                    if let genre = Genres.shared.tvGenres[genreIds[i]] {
                        if i == genreIds.count - 1 {
                            self.genres.append(genre)
                        } else {
                            let comma = ", "
                            self.genres.append(genre + comma)
                        }
                    }
                    
                default:
                    break
                }
            }
        }
        
        self.mediaType = mediaType
        self.id = id
    }
    
}
