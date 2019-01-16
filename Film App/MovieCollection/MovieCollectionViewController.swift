import UIKit

class MovieCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var collectionId: Int!
    var navigator: ProjectNavigator?
    
    var coverURL: String?
    var parts = [DatabaseObject]() {
        didSet {
            setPageControl()
            collectionView.reloadData()
        }
    }
    
    var pageControl: UIPageControl!

    init(collectionViewLayout layout: UICollectionViewLayout, collectionId id: Int, navigator: ProjectNavigator?) {
        self.collectionId = id
        self.navigator = navigator
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isPagingEnabled = true

        // Register cell classes
        self.collectionView.register(UINib(nibName: "PosterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PosterCell")
        
        loadCollectionInfo()
    }
    
    private func loadCollectionInfo() {
        ConfigurationService.client.loadMovieCollection(collectionId: collectionId) { (result) in
            guard let result = result else {
                // TODO: Show error
                return }
            
            if let coverPath = result.cover,
                let url = URL(string: "https://image.tmdb.org/t/p/w780\(coverPath)") {
                let coverController = CollectionCoverViewController(coverUrl: url)
                coverController.modalTransitionStyle = .crossDissolve
                coverController.modalPresentationStyle = .overFullScreen
               
                self.present(coverController, animated: true, completion: {
                    if !result.parts.isEmpty {
                        self.parts = result.parts
                    }
                })
            } else {
                if !result.parts.isEmpty {
                    self.parts = result.parts
                }
            }
        }
    }
    
    private func setPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = parts.count
        pageControl.isUserInteractionEnabled = false
        self.navigationItem.titleView = pageControl
        
        /* If wanted pageControl as a subview
         
        self.view.addSubview(self.pageControl)
        self.view.bringSubviewToFront(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.bottomAnchor.constraint(equalTo: self.collectionView.bottomAnchor, constant: -64.0).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor).isActive = true
         
        */
    }

    // MARK: Protocols implementation

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return parts.count

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCollectionViewCell

            cell.configure(withImage: parts[indexPath.row].image)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieId = parts[indexPath.item].id
        navigator?.navigate(to: .movie(id: movieId, type: .movie))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.width
        var height: CGFloat = 550.0
        
        if let navigationController = self.navigationController,
            let tabBarController = self.tabBarController {
            height = self.view.frame.height - navigationController.navigationBar.frame.height - tabBarController.tabBar.frame.height
        }
        
        return CGSize(width: width, height: height)
        
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    
}
