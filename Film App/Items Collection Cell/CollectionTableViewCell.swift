import UIKit

enum CollectionColorMode {
    case light
    case dark
}

class CollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    
    public var data = [DatabaseObject]() {
        didSet {
            itemsCollectionView.reloadData()
            itemsCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    var currentColorMode: CollectionColorMode = .light {
        didSet {
            itemsCollectionView.reloadData()
        }
    }
    var navigator: ProjectNavigator?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemsCollectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
    }
    
    @IBAction func seeAllButtonPressed(_ sender: UIButton) {
        navigator?.navigate(to: .list)
    }
    

    func setDarkColorMode() {
        
        currentColorMode = .dark
        self.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.1294117719, blue: 0.1411764771, alpha: 1)
        headerView.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.1294117719, blue: 0.1411764771, alpha: 1)
        headerTitle.textColor = UIColor.white
        itemsCollectionView.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.1294117719, blue: 0.1411764771, alpha: 1)
    }
}

extension CollectionTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCollectionViewCell
        cell.configure(with: data[indexPath.item], colorMode: currentColorMode)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let item = data[indexPath.item]
        
        if item.mediaType != MediaType.person {
            navigator?.navigate(to: .movie(id: item.id, type: item.mediaType))
        }
    }
    
}
