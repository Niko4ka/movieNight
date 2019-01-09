import UIKit

class CollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    
    public var data = [DatabaseObject]() {
        didSet {
            itemsCollectionView.reloadData()
        }
    }
    var coordinator: MovieCoordinator?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemsCollectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
        
        itemsCollectionView.reloadData()
    }

}

extension CollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionViewCell
        
        cell.configure(with: data[indexPath.item])
        // Configure the cell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Select item")
        
        let item = data[indexPath.item]
        
        if item.mediaType != MediaType.person {
            coordinator?.pushMovieController(id: item.id, type: item.mediaType)
        }
    }
    
}
