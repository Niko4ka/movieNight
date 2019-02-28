import UIKit
import Kingfisher

class PersonMovieTableViewCell: UITableViewCell {
    
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var personRoleLabel: UILabel!
    var id: Int!
    var mediaType: MediaType!
    
    weak var colorDelegate: ColorThemeCellObserver! {
        didSet {
            setColorTheme()
        }
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
    
    private func setColorTheme() {
        if colorDelegate.isDarkTheme {
            backgroundColor = .darkThemeBackground
            moviePosterImageView.backgroundColor = .darkThemeBackground
            movieTitleLabel.superview?.backgroundColor = .darkThemeBackground
            movieTitleLabel.textColor = .white
            personRoleLabel.textColor = .lightText
        } else {
            backgroundColor = .white
            moviePosterImageView.backgroundColor = .white
            movieTitleLabel.superview?.backgroundColor = .white
            movieTitleLabel.textColor = .darkText
            personRoleLabel.textColor = .darkGray
        }
    }

}
