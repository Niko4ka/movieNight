import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieGenre: UILabel!
    public var objectID: Int!
    public var mediaType: MediaType!
    

    func configure(with object: DatabaseObject, colorMode: CollectionColorMode) {
        
        self.objectID = object.id
        self.mediaType = object.mediaType
        movieTitle.text = object.title
        movieGenre.text = object.genres
        
        if let imagePath = object.image, let url = URL(string: "https://image.tmdb.org/t/p/w500/\(imagePath)") {
            movieImage.kf.indicatorType = .activity
            movieImage.contentMode = .scaleAspectFit
            movieImage.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (result) in
                self.setNeedsLayout()
            })
        } else {
            movieImage.image = UIImage(named: "noPoster")
        }
        
        if colorMode == .dark {
            setDarkColorMode()
        } else {
            setLightColorMode()
        }
    }
    
    private func setDarkColorMode() {
        
        mainView.backgroundColor = .darkThemeBackground
        movieTitle.textColor = .white
        movieGenre.textColor = .lightGray
    }
    
    private func setLightColorMode() {
        
        mainView.backgroundColor = .white
        movieTitle.textColor = .black
        movieGenre.textColor = .darkGray
    }
    
}
