import UIKit
import CoreData

class WishlistTableViewController: UITableViewController {
    
    var fetchedResultController: NSFetchedResultsController<Movie>!
    
    lazy var sectionSegmentedControl: UISegmentedControl = {
       
        let items = ["Movies", "TV Shows"]
        var segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(sectionSegmentedControlValueChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    struct Predicates {
        static let tvPredicate = NSPredicate(format: "mediaType.name CONTAINS[cd] 'tv'")
        static let moviePredicate = NSPredicate(format: "mediaType.name CONTAINS[cd] 'movie'")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = sectionSegmentedControl
        navigationItem.leftBarButtonItem = editButtonItem

        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "WishlistTableViewCell", bundle: nil), forCellReuseIdentifier: "WishlistCell")
        
        fetchData(predicate: Predicates.moviePredicate)
    }
    
    @objc private func sectionSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            fetchData(predicate: Predicates.tvPredicate)
        } else {
            fetchData(predicate: Predicates.moviePredicate)
        }
        tableView.reloadData()
    }
    
    private func fetchData(predicate: NSPredicate? = nil) {
        
        fetchedResultController = CoreDataManager.shared.fetchDataWithController(for: Movie.self, predicate: predicate)
        fetchedResultController.delegate = self
        fetchedObjectsCheck(predicate: predicate)
    }
    
    private func fetchedObjectsCheck(predicate: NSPredicate? = nil) {
        
        guard let objects = fetchedResultController.fetchedObjects else {
            return
        }
        
        if objects.count == 0 {
            let backgroundView = makeNoResultsView()
            tableView.backgroundView = backgroundView
        } else {
          tableView.backgroundView = nil
        }
    }
    
    private func makeNoResultsView() -> UIView {
        
        let backgroundView = UIView()
        backgroundView.frame.size = CGSize(width: view.bounds.width, height: view.bounds.height)
        backgroundView.backgroundColor = UIColor.white
        let label = UILabel()
        backgroundView.addSubview(label)
        label.text = "No movies in wishlidt yet"
        label.font = UIFont.systemFont(ofSize: 15.0)
        label.textColor = #colorLiteral(red: 0.4352941215, green: 0.4431372583, blue: 0.4745098054, alpha: 1)
        label.textAlignment = .center
        
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -0.15 * backgroundView.frame.height).isActive = true
        label.widthAnchor.constraint(equalToConstant: backgroundView.frame.width - 32).isActive = true
        
        return backgroundView
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
            cell.configure(with: item)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! WishlistTableViewCell
        let storyboard = UIStoryboard(name: "Movie", bundle: nil)
        let movieController = storyboard.instantiateViewController(withIdentifier: "MovieTableViewController") as! MovieTableViewController
        movieController.movieId = cell.id
        if let type = cell.mediaType {
            movieController.mediaType = type
        } else {
            print("Problems with type")
            return
        }
        
        self.navigationController?.pushViewController(movieController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let removeFromWishlist = UITableViewRowAction(style: .destructive, title: "Remove from wishlist") { (action, indexPath) in
            
            let item = self.fetchedResultController.object(at: indexPath)
            CoreDataManager.shared.delete(object: item)
        }
        
        return [removeFromWishlist]
    }

}

extension WishlistTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type {
        case .insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
                fetchedObjectsCheck()
            }
            
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
                fetchedObjectsCheck()
            }
            
        case .move:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! WishlistTableViewCell
                let item = fetchedResultController.object(at: indexPath)
                cell.configure(with: item)
            }
            
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! WishlistTableViewCell
                let item = fetchedResultController.object(at: indexPath)
                cell.configure(with: item)
            }
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
