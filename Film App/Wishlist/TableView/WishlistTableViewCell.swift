import UIKit

class WishlistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var releasedDateLabel: UILabel!
    @IBOutlet weak var ratingStackView: RatingControl!
    
    var isDarkTheme: Bool! {
        didSet {
            setColorTheme()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with movie: Movie) {
        posterImageView.image = movie.poster as? UIImage
        titleLabel.text = movie.title
        genresLabel.text = movie.genres
        releasedDateLabel.text = movie.releasedDate
        if !ratingStackView.subviews.isEmpty {
            ratingStackView.removeArrangedViews()
        }
        ratingStackView.setRating(movie.rating, from: Int(movie.voteCount))
    }
    
    private func setColorTheme() {
        if isDarkTheme {
            contentView.backgroundColor = .darkThemeBackground
            backgroundColor = .darkThemeBackground
            titleLabel.textColor = .white
            genresLabel.textColor = .lightGray
            releasedDateLabel.textColor = .white
            titleLabel.superview?.backgroundColor = .darkThemeBackground
            
        } else {
            contentView.backgroundColor = .white
            backgroundColor = .white
            titleLabel.textColor = .darkText
            genresLabel.textColor = .darkGray
            releasedDateLabel.textColor = .darkText
            titleLabel.superview?.backgroundColor = .white
        }
    }

    
}
