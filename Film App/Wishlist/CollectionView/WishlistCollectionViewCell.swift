import UIKit

class WishlistCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "WishlistCollectionViewCell"
    
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let delta = 1 - (CatalogLayoutConstants.focusedCellHeight - frame.height) / (CatalogLayoutConstants.focusedCellHeight - CatalogLayoutConstants.standardCellHeight)
        
        let minAlpha: CGFloat = 0.25
        let maxAlpha: CGFloat = 0.75
        coverView.alpha = maxAlpha - (delta * (maxAlpha - minAlpha))
        
        let scale = max(delta, 0.5)
        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
        genreLabel.alpha = delta
        releaseDateLabel.alpha = delta
    }
    
    func configure(with movie: Movie) {
        if let image = movie.backdrop as? UIImage {
            backdropImageView.image = image
        }
        
        titleLabel.text = movie.title
        genreLabel.text = movie.genres
        releaseDateLabel.text = movie.releasedDate
    }

}
