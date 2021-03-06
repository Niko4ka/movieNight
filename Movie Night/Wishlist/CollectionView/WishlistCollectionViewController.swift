import UIKit
import CoreData

class WishlistCollectionViewController: UICollectionViewController, WishlistMainViewProtocol, ColorThemeCellObserver {
  
    var navigator: ProjectNavigator?
    var fetchedResultController: NSFetchedResultsController<Movie>!
    
    lazy var sectionSegmentedControl: UISegmentedControl = {
        
        let items = ["Movies", "TV Shows"]
        var segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(sectionSegmentedControlValueChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    var isDarkTheme: Bool = false {
        didSet {
            changeBackground()
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar()
        configureCollectionView()
        fetchData(predicate: WishlistPredicates.moviePredicate)

    }
    
    func configureNavigationBar() {
        
        if let parent = self.parent {
            parent.navigationItem.titleView = sectionSegmentedControl
            parent.navigationItem.leftBarButtonItem = nil
        }
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .white
        collectionView.decelerationRate = .fast
        collectionView.register(UINib(nibName: "WishlistCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: WishlistCollectionViewCell.reuseIdentifier)
    }
    
    private func changeBackground() {
        if isDarkTheme {
            sectionSegmentedControl.tintColor = .lightBlueTint
            collectionView.backgroundColor = .darkThemeBackground
        } else {
            sectionSegmentedControl.tintColor = .defaultBlueTint
            collectionView.backgroundColor = .white
        }
    }
    
    private func fetchData(predicate: NSPredicate? = nil) {
        
        fetchedResultController = CoreDataManager.shared.fetchDataWithController(for: Movie.self, predicate: predicate)
        fetchedResultController.delegate = self
        fetchedObjectsCheck(predicate: predicate)
    }
    
    func fetchedObjectsCheck(predicate: NSPredicate? = nil) {
        
        guard let objects = fetchedResultController.fetchedObjects else { return }
        
        if objects.count == 0 {
            let backgroundView = UIView.getEmptyView(withText: "No movies in wishlist yet")
            collectionView.backgroundView = backgroundView
            NotificationService.shared.removeReminderNotification()
        } else {
            collectionView.backgroundView = nil
            NotificationService.shared.planReminderNotification()
        }
    }
    
    @objc private func sectionSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            fetchData(predicate: WishlistPredicates.tvPredicate)
        } else {
            fetchData(predicate: WishlistPredicates.moviePredicate)
        }
        collectionView.reloadData()
    }
    
    func showActivity(for cell: WishlistCollectionViewCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let object = self.fetchedResultController.object(at: indexPath)
        
        var items: [Any]!
        if let title = object.title {
            if let releaseYear = object.releasedDate?.suffix(4), let genres = object.genres, let mediaType = object.mediaType?.name, let poster = object.poster as? UIImage {
                let releaseYearString = String(releaseYear)
                let description = title + " (" + releaseYearString + ")" + "\n" + genres
                let url = "https://www.themoviedb.org/" + mediaType + "/" + "\(object.id)"
                items = [description, url, poster]
            } else {
                items = [title]
            }
        }
        
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
        
    }
    
    // MARK: CollectionView methods
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let frc = fetchedResultController, let sections = frc.sections else {
            return 0
        }

        return sections.count

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let frc = fetchedResultController, let sections = frc.sections else {
            return 0
        }

        return sections[section].numberOfObjects

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WishlistCollectionViewCell.reuseIdentifier, for: indexPath) as! WishlistCollectionViewCell
        let item = fetchedResultController.object(at: indexPath)
        cell.delegate = self
        cell.configure(with: item)

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let layout = collectionViewLayout as? CatalogCollectionViewLayout else { return }
        
        if indexPath.item == layout.focusedItemIndex {
    
            let item = fetchedResultController.object(at: indexPath)
            if let mediaType = item.mediaType, let mediaTypeName = mediaType.name, let type = MediaType(rawValue: mediaTypeName) {
                navigator?.navigate(to: .movie(id: Int(item.id), type: type))
            }
            
        } else {
            let offset = layout.scrollOffset * CGFloat(indexPath.item)
            if collectionView.contentOffset.y != offset {
                collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
            }

        }
        
        
    }
    
}
