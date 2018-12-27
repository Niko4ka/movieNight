//
//  ItemCollectionViewCell.swift
//  Film App
//
//  Created by Вероника Данилова on 11/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieGenre: UILabel!
    public var objectID: Int!
    public var mediaType: MediaType!
    

    func configure(with object: DatabaseObject) {
        
        self.objectID = object.id
        self.mediaType = object.mediaType
        movieTitle.text = object.title
        movieGenre.text = object.genres
        
        if let imagePath = object.image, let url = URL(string: "https://image.tmdb.org/t/p/w500/\(imagePath)") {
            movieImage.kf.indicatorType = .activity
            movieImage.contentMode = .scaleAspectFit
            movieImage.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (result) in
                self.setNeedsLayout()
            })
        } else {
            movieImage.image = UIImage(named: "noPoster")
        }
        
    }

}
