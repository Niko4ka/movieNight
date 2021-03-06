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
    
    var isLoading: Bool = false {
        didSet {
            updateLoading()
        }
    }
    
    private func updateLoading() {
        if isLoading {
            let activity = UIActivityIndicatorView(style: .white)
            activity.startAnimating()
            collectionView.backgroundView = activity
        } else {
            collectionView.backgroundView = nil
        }
    }

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
        collectionView.register(UINib(nibName: "PosterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PosterCell")
        
        loadCollectionInfo()
    }
    
    private func loadCollectionInfo() {
        
        isLoading = true
        
        Client.shared.loadMovieCollection(collectionId: collectionId) { (result) in
            
            switch result {
            case .success(let collectionInfo):
                guard let coverPath = collectionInfo.cover,
                    let url = URL(string: "https://image.tmdb.org/t/p/w780\(coverPath)") else { return }
                
                Client.shared.loadImage(url: url) { (result) in
                    switch result {
                    case .success(let data):
                        let coverController = CollectionCoverViewController(data: data)
                        coverController.modalTransitionStyle = .crossDissolve
                        coverController.modalPresentationStyle = .overFullScreen
                        self.present(coverController, animated: true, completion: {
                            self.isLoading = false
                            if !collectionInfo.parts.isEmpty {
                                self.parts = collectionInfo.parts
                            }
                        })
                    case .error:
                        self.isLoading = false
                        if !collectionInfo.parts.isEmpty {
                            self.parts = collectionInfo.parts
                        }
                    }
                }
            case .error:
                self.isLoading = false
                self.showError(completion: {
                    self.navigator?.pop()
                })
            }
        }
    }
    
    /// Sets UIPageControl as NavigationItem titleView
    private func setPageControl() {
        pageControl = UIPageControl()
        pageControl.numberOfPages = parts.count
        pageControl.isUserInteractionEnabled = false
        self.navigationItem.titleView = pageControl
        
        /* If required pageControl as a subview
         
        self.view.addSubview(self.pageControl)
        self.view.bringSubviewToFront(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.bottomAnchor.constraint(equalTo: self.collectionView.bottomAnchor, constant: -64.0).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor).isActive = true
         
        */
    }

    // MARK: Protocols implementation

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
