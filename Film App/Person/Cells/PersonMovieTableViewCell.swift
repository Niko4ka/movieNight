//
//  PersonMovieTableViewCell.swift
//  Film App
//
//  Created by Вероника Данилова on 27/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import Kingfisher

class PersonMovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var personRoleLabel: UILabel!
    var id: Int!
    var mediaType: MediaType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public func configure(with movie: PersonMovie) {
        
        id = movie.id
        mediaType = movie.mediaType
        personRoleLabel.text = movie.character
        movieTitleLabel.text = movie.title
        
        if let year = movie.year, !year.isEmpty {
            movieTitleLabel.text?.append(" (\(year))")
        }
        
        if let url = movie.posterUrl {
            moviePosterImageView.kf.indicatorType = .activity
            moviePosterImageView.contentMode = .scaleAspectFit
            moviePosterImageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (result) in
                self.setNeedsLayout()
            })
        } else {
            moviePosterImageView.image = UIImage(named: "noPoster")
        }
        
    }

}
