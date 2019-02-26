import UIKit
import CoreData

class WishlistTableViewController: UITableViewController, WishlistColorThemeObserver {
    
    // MARK: - Outlets
    
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
            tableView.reloadData()
        }
    }
    
    // MARK: - View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        configureTableView()
        fetchData(predicate: WishlistPredicates.moviePredicate)
        
        addColorThemeObservers()
    }
    
    private func configureNavigationBar() {
        
        if let parent = self.parent {
            parent.navigationItem.titleView = sectionSegmentedControl
            parent.navigationItem.leftBarButtonItem = editButtonItem
        } else {
            
        }
    }
    
    private func configureTableView() {
        tableView.bounces = false
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "WishlistTableViewCell", bundle: nil), forCellReuseIdentifier: "WishlistCell")
    }
    
    private func changeBackground() {
        if isDarkTheme {
            sectionSegmentedControl.tintColor = .lightBlueTint
            tableView.backgroundColor = .darkThemeBackground
        } else {
            sectionSegmentedControl.tintColor = .defaultBlueTint
            tableView.backgroundColor = .white
        }
    }
    
    // MARK: - Fetch data
    
    private func fetchData(predicate: NSPredicate? = nil) {
        
        fetchedResultController = CoreDataManager.shared.fetchDataWithController(for: Movie.self, predicate: predicate)
        fetchedResultController.delegate = self
        fetchedObjectsCheck(predicate: predicate)
    }
    
    func fetchedObjectsCheck(predicate: NSPredicate? = nil) {
        
        guard let objects = fetchedResultController.fetchedObjects else {
            return
        }
        
        if objects.count == 0 {
            let backgroundView = UIView.getEmptyView(withText: "No movies in wishlist yet")
            tableView.backgroundView = backgroundView
            NotificationService.shared.removeReminderNotification()
        } else {
            tableView.backgroundView = nil
            NotificationService.shared.planReminderNotification()
        }
    }
    
    // MARK: - Private functions
    
    /// Shows UIActivityViewController
    ///
    /// - Parameter items: information to pass
    private func showActivity(forItems items: [Any]) {
        let activityController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    
    @objc private func sectionSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            fetchData(predicate: WishlistPredicates.tvPredicate)
        } else {
            fetchData(predicate: WishlistPredicates.moviePredicate)
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let frc = fetchedResultController, let sections = frc.sections else {
            return 0
        }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let frc = fetchedResultController, let sections = frc.sections else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WishlistCell", for: indexPath)
        
        if let cell = cell as? WishlistTableViewCell {
            let item = fetchedResultController.object(at: indexPath)
            cell.isDarkTheme = isDarkTheme
            cell.configure(with: item)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let item = fetchedResultController.object(at: indexPath)
        if let mediaType = item.mediaType, let mediaTypeName = mediaType.name, let type = MediaType(rawValue: mediaTypeName) {
            navigator?.navigate(to: .movie(id: Int(item.id), type: type))
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let removeFromWishlist = UITableViewRowAction(style: .destructive, title: "Remove from wishlist") { (action, indexPath) in
            
            let item = self.fetchedResultController.object(at: indexPath)
            CoreDataManager.shared.delete(object: item)
        }
        
        let share = UITableViewRowAction(style: .default, title: "Share") { (action, indexPath) in
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
            
            self.showActivity(forItems: items)
    
        }
        share.backgroundColor = .defaultBlueTint
        
        return [removeFromWishlist, share]
    }
    
}
