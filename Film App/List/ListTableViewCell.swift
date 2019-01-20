import UIKit
import Kingfisher

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with object: DatabaseObject) {
        
        if let imagePath = object.image, let url = URL(string: "https://image.tmdb.org/t/p/w500/\(imagePath)") {
            posterImageView.kf.indicatorType = .activity
            posterImageView.contentMode = .scaleAspectFit
            posterImageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (result) in
                self.setNeedsLayout()
            })
        } else {
            posterImageView.image = UIImage(named: "noPoster")
        }
        
        movieTitleLabel.text = object.title
        genresLabel.text = object.genres
        
    }
    
}
