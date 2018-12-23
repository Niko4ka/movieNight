//
//  MovieReview.swift
//  Film App
//
//  Created by Вероника Данилова on 23/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import Foundation

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
