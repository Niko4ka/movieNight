//
//  Wishlist.swift
//  Film App
//
//  Created by Вероника Данилова on 24/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

struct Wishlist {
    
    static var movies: [WishlistMovie] = []
}

struct WishlistMovie {
    var id: Int
    var mediaType: MediaType
    var title: String
    var genres: String
    var releasedDate: String
    var poster: UIImage
    var rating: Double
    var voteCount: Int
}
