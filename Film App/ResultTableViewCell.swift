//
//  ResultTableViewCell.swift
//  Film App
//
//  Created by Вероника Данилова on 11/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import Kingfisher

class ResultTableViewCell: UITableViewCell {
    
    var objectID: Int!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with object: DatabaseObject) {
        
        self.objectID = object.id
        self.textLabel?.text = object.title
        self.detailTextLabel?.text = object.mediaType

        let url = URL(string: "https://image.tmdb.org/t/p/w500/\(object.image)")
        self.imageView?.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (result) in
            self.setNeedsLayout()
        })

        
    }

}
