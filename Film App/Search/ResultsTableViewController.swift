import UIKit

class ResultsTableViewController: UITableViewController {
    
    public var data = [(title: String, objects: [DatabaseObject])]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var navigator: ProjectNavigator?
    
    init(navigator: ProjectNavigator) {
        self.navigator = navigator
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
        
        if traitCollection.forceTouchCapability == .available {
            print("Available")
            registerForPreviewing(with: self, sourceView: view)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let title = data[indexPath.row].title
        let items = data[indexPath.row].objects
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
        cell.coordinator = self
        cell.headerTitle.text = title
        cell.data = items
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }


}

extension ResultsTableViewController: MovieCoordinator {
    func showMovie(id: Int, type: MediaType) {
        
        navigator?.navigate(to: .movie(id: id, type: type))
    }
    
}

extension ResultsTableViewController: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let tableCellIndexPath = tableView.indexPathForRow(at: location),
            let tableViewCell = tableView.cellForRow(at: tableCellIndexPath) as? CollectionTableViewCell,
            let collectionView = tableViewCell.itemsCollectionView else { return nil }
        
        let collectionViewLocation = tableView.convert(location, to: collectionView)
        
        guard let collectionViewIndexPath = collectionView.indexPathForItem(at: collectionViewLocation),
            let collectionViewCell = collectionView.cellForItem(at: collectionViewIndexPath) as? ItemCollectionViewCell else { return nil }
        
        let storyboard = UIStoryboard(name: "Movie", bundle: nil)
        guard let movieController = storyboard.instantiateViewController(withIdentifier: "MovieTableViewController") as? MovieTableViewController else { return nil }
        
        movieController.movieId = collectionViewCell.objectID
        movieController.mediaType = collectionViewCell.mediaType
        movieController.navigator = navigator
        movieController.preferredContentSize = CGSize(width: 0.0, height: 500.0)
        previewingContext.sourceRect = collectionViewCell.frame
        
        return movieController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}
