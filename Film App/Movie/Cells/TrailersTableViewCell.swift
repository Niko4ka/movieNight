import UIKit

class TrailersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var trailersCollectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    public var trailers: [MovieTrailer] = []
    weak var videoPlayer: VideoPlayerDelegate?
    weak var colorDelegate: ColorThemeCellObserver! {
        didSet {
            setColorTheme()
            trailersCollectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        trailersCollectionView.register(UINib(nibName: "TrailerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Trailer")
        trailersCollectionView.delegate = self
        trailersCollectionView.dataSource = self
        trailersCollectionView.reloadData()
    }
    
    private func setColorTheme() {
        
        if colorDelegate.isDarkTheme {
            trailersCollectionView.backgroundColor = .darkThemeBackground
            backgroundColor = .darkThemeBackground
            titleLabel.textColor = .white
        } else {
            trailersCollectionView.backgroundColor = .white
            backgroundColor = .white
            titleLabel.textColor = .darkText
        }
        
    }

}

extension TrailersTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trailers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Trailer", for: indexPath) as! TrailerCollectionViewCell
        cell.isDarkTheme = colorDelegate.isDarkTheme
        cell.configure(with: trailers[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        videoPlayer?.playVideo(withId: trailers[indexPath.item].id)
    }

}
