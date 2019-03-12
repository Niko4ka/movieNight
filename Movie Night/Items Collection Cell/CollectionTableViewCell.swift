import UIKit

enum CollectionColorMode {
    case light
    case dark
}

class CollectionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    public var data = [DatabaseObject]() {
        didSet {
            activityIndicator.stopAnimating()
            itemsCollectionView.isHidden = false
            itemsCollectionView.reloadData()
            itemsCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            headerViewHeight.constant = 30
        }
    }
    
    var currentColorMode: CollectionColorMode = .light {
        didSet {
            itemsCollectionView.reloadData()
        }
    }
    
    weak var colorDelegate: ColorThemeCellObserver? {
        didSet {
            if colorDelegate!.isDarkTheme {
                setDarkColorMode()
            } else {
                setLightColorMode()
            }
        }
    }
    
    var navigator: ProjectNavigator?
    var requestType: ListRequest?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemsCollectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
    }
    
    @IBAction func seeAllButtonPressed() {
        if let request = requestType {
            navigator?.navigate(to: .list(listRequest: request))
        }
    }

    func setDarkColorMode() {
        
        currentColorMode = .dark
        self.backgroundColor = .darkThemeBackground
        headerView.backgroundColor = .darkThemeBackground
        headerTitle.textColor = .white
        itemsCollectionView.backgroundColor = .darkThemeBackground
    }
    
    func setLightColorMode() {
        
        currentColorMode = .light
        self.backgroundColor = .white
        headerView.backgroundColor = .white
        headerTitle.textColor = .black
        itemsCollectionView.backgroundColor = .white
    }
    
    func removeHeaderView() {
        headerViewHeight.constant = 0
        self.setNeedsLayout()
    }
    
    func showActivityIndicator(withHeader needHeader: Bool) {
        
        if !needHeader {
            headerView.alpha = 0
        }
        
        itemsCollectionView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
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
