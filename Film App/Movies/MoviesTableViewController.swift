import UIKit

class MoviesTableViewController: UITableViewController {
    
    var nowPlaying = [DatabaseObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var popular = [DatabaseObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var upcoming = [DatabaseObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var navigator: ProjectNavigator?
    var slider: SliderHeaderView?

    override func viewDidLoad() {
        super.viewDidLoad()
        slider = SliderHeaderView(navigator: navigator)
        tableView.tableHeaderView = slider
        tableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
        tableView.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.1294117719, blue: 0.1411764771, alpha: 1)
        tableView.bounces = false
        tableView.allowsSelection = false
        loadData()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: view)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let slider = slider, let timer = slider.timer, timer.isValid {
            timer.invalidate()
        }
    }
    
    private func loadData() {
        
        ConfigurationService.client.loadMoviesCategory(.nowPlaying) { (movies) in
            self.nowPlaying = movies
        }
        
        ConfigurationService.client.loadMoviesCategory(.popular) { (movies) in
            self.popular = movies
        }
        
        ConfigurationService.client.loadMoviesCategory(.upcoming) { (movies) in
            self.upcoming = movies
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
        if indexPath.row == 0 {
            cell.data = nowPlaying
            cell.navigator = navigator
            cell.headerTitle.text = "Now in cinemas"
            cell.setDarkColorMode()
            return cell
        } else if indexPath.row == 1 {
            cell.data = popular
            cell.navigator = navigator
            cell.headerTitle.text = "Popular"
            cell.setDarkColorMode()
            return cell
        } else {
            cell.data = upcoming
            cell.navigator = navigator
            cell.headerTitle.text = "Upcoming"
            cell.setDarkColorMode()
            return cell
        }
        
    }
 

}

extension MoviesTableViewController: UIViewControllerPreviewingDelegate {
    
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
