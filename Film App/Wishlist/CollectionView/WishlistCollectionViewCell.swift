import UIKit

class WishlistCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "WishlistCollectionViewCell"
    
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    
    weak var delegate: WishlistCollectionViewController?
    var poster: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longPress.numberOfTouchesRequired = 1
        addGestureRecognizer(longPress)
    }
    

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        let delta = 1 - (CatalogLayoutConstants.focusedCellHeight - frame.height) / (CatalogLayoutConstants.focusedCellHeight - CatalogLayoutConstants.standardCellHeight)
        
        var minAlpha: CGFloat = 0.25
        if let delegate = delegate {
            if !delegate.isDarkTheme {
                minAlpha = 0.45
            }
        }
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
        
        if let posterImage = movie.poster as? UIImage {
            poster = posterImage
        }
        
        setColorTheme()
    }
    
    @objc func longPressAction() {
        
        guard let delegate = self.delegate, let indexPath = delegate.collectionView.indexPath(for: self) else { return }
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if let movieName = titleLabel.text {
            sheet.title = "What do you want to do with \"\(movieName)\"?"
        }
        
        let delete = UIAlertAction(title: "Remove from wishlist", style: .destructive) { _ in
            
            let item = delegate.fetchedResultController.object(at: indexPath)
            CoreDataManager.shared.delete(object: item)
        }
        
        let share = UIAlertAction(title: "Share", style: .default) { _ in
            delegate.showActivity(for: self)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(share)
        sheet.addAction(delete)
        sheet.addAction(cancel)
        
        delegate.present(sheet, animated: true, completion: nil)
    }
    
    private func setColorTheme() {
        guard let delegate = self.delegate else { return }
        
        if delegate.isDarkTheme {
            coverView.backgroundColor = .black
            titleLabel.textColor = .white
            genreLabel.textColor = .white
            releaseDateLabel.textColor = .white
        } else {
            coverView.backgroundColor = .white
            titleLabel.textColor = .black
            genreLabel.textColor = .darkText
            releaseDateLabel.textColor = .darkText
        }
    }

}
