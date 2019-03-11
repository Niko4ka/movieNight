import UIKit
import Kingfisher

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    weak var colorDelegate: ColorThemeCellObserver! {
        didSet {
            setColorTheme()
        }
    }
    
    func configure(with object: DatabaseObject?) {
        
        if let object = object {
            activityIndicator.isHidden = true
            movieTitleLabel.text = object.title
            movieTitleLabel.alpha = 1
            genresLabel.text = object.genres
            genresLabel.alpha = 1
            setPosterFromPath(object.image)
        } else {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            movieTitleLabel.alpha = 0
            genresLabel.alpha = 0
            posterImageView.alpha = 0
        }
        
    }
    
    private func setPosterFromPath(_ path: String?) {
        posterImageView.alpha = 1.0
        if let imagePath = path, let url = URL(string: "https://image.tmdb.org/t/p/w500/\(imagePath)") {
            posterImageView.kf.indicatorType = .activity
            posterImageView.contentMode = .scaleAspectFit
            posterImageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (result) in
                self.setNeedsLayout()
            })
        } else {
            posterImageView.image = UIImage(named: "noPoster")
        }
    }
    
    private func setColorTheme() {
        
        if colorDelegate.isDarkTheme {
            contentView.backgroundColor = .darkThemeBackground
            movieTitleLabel.textColor = .white
            if let containerView = movieTitleLabel.superview {
                containerView.backgroundColor = .darkThemeBackground
            }
        } else {
            contentView.backgroundColor = .white
            movieTitleLabel.textColor = .darkText
            if let containerView = movieTitleLabel.superview {
                containerView.backgroundColor = .white
            }
        }
        
    }
    
}
