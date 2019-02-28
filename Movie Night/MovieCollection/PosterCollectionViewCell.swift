import UIKit
import Kingfisher

class PosterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    
    func configure(withImage imagePath: String?) {
        
        if let imagePath = imagePath,
            let url = URL(string: "https://image.tmdb.org/t/p/w780\(imagePath)") {
            posterImageView.kf.indicatorType = .activity
            posterImageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (result) in
                self.setNeedsLayout()
            })
        }
        
    }
    
}
