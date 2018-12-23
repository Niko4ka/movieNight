//
//  TrailerCollectionViewCell.swift
//  Film App
//
//  Created by Вероника Данилова on 18/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import Kingfisher

class TrailerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    var id: String!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(with trailer: MovieTrailer) {
        
        thumbnailImageView.kf.setImage(with: trailer.thumbnailUrl)
        titleLabel.text = trailer.title
        durationLabel.text = trailer.duration
        
        id = trailer.id
    }
    
}
