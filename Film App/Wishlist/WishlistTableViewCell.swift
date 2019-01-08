import UIKit

class WishlistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var releasedDateLabel: UILabel!
    @IBOutlet weak var ratingStackView: RatingControl!
    var id: Int!
    var mediaType: MediaType?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with movie: Movie) {
        id = Int(movie.id)
        if let value = movie.mediaType?.name {
            mediaType = MediaType(rawValue: value)
        }
        posterImageView.image = movie.poster as? UIImage
        titleLabel.text = movie.title
        genresLabel.text = movie.genres
        releasedDateLabel.text = movie.releasedDate
        if !ratingStackView.subviews.isEmpty {
            ratingStackView.removeArrangedViews()
        }
        ratingStackView.setRating(movie.rating, from: Int(movie.voteCount))
    }

    
}
