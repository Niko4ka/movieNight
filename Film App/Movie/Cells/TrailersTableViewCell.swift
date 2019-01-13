import UIKit

class TrailersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var trailersCollectionView: UICollectionView!
    
    public var trailers: [MovieTrailer] = []
    var videoPlayer: VideoPlayerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        trailersCollectionView.delegate = self
        trailersCollectionView.dataSource = self
        trailersCollectionView.reloadData()
    }

}

extension TrailersTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trailers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Trailer", for: indexPath) as! TrailerCollectionViewCell
        cell.configure(with: trailers[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        videoPlayer?.playVideo(withId: trailers[indexPath.item].id)
    }

}
