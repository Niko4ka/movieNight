import UIKit
import Kingfisher

class TrailerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    var isDarkTheme: Bool! {
        didSet {
            setColorTheme()
        }
    }

    func configure(with trailer: MovieTrailer) {
        
        thumbnailImageView.kf.setImage(with: trailer.thumbnailUrl)
        titleLabel.text = trailer.title
        durationLabel.text = trailer.duration
    }
    
    private func setColorTheme() {
        if isDarkTheme {
            titleLabel.textColor = .white
        } else {
            titleLabel.textColor = .darkText
        }
    }
    
}
