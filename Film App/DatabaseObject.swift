//
//  DatabaseObject.swift
//  Film App
//
//  Created by Вероника Данилова on 11/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import Foundation

struct DatabaseObject {
    
    var mediaType: String
    var image: String
    var genreIds: [Int]?
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
            self.genreIds = genreIds
        }
        
        self.mediaType = mediaType
        self.id = id
    }
    
//    private enum CodingKeys: String, CodingKey {
//        case title = "title"
//        case name = "name"
//        case mediaType = "media_type"
//        case posterPath = "poster_path"
//        case genreIds = "genre_ids"
//        case id = "id"
//    }
}

//extension DatabaseObject: Decodable {
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        mediaType = try values.decode(String.self, forKey: .mediaType)
//        posterPath = try values.decode(String.self, forKey: .posterPath)
//        id = try values.decode(Int.self, forKey: .id)
//        genreIds = try values.decode(Array<Int>.self, forKey: .genreIds)
//
//        if let objectTitle = try? values.decode(String.self, forKey: .title) {
//            title = objectTitle
//        } else {
//            title = try values.decode(String.self, forKey: .name)
//        }
//    }
//}
