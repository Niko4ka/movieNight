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
    
    var genres = [String]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var sectionSegmentedControl: UISegmentedControl = {
        
        let items = ["Categories", "Genres"]
        var segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(sectionSegmentedControlValueChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()
    
    var navigator: ProjectNavigator?
    var slider: SliderHeaderView?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = sectionSegmentedControl
        
        slider = SliderHeaderView(navigator: navigator)
        tableView.tableHeaderView = slider
        tableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GenreCell")
        tableView.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.1294117719, blue: 0.1411764771, alpha: 1)
        tableView.bounces = false
        tableView.allowsSelection = false
        loadCategoriesData()
        
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
    
    private func loadCategoriesData() {
        
        Client.shared.loadMoviesCategory(.nowPlaying) { (movies) in
            self.nowPlaying = movies
        }
        
        Client.shared.loadMoviesCategory(.popular) { (movies) in
            self.popular = movies
        }
        
        Client.shared.loadMoviesCategory(.upcoming) { (movies) in
            self.upcoming = movies
        }
    }
    
    private func showGenres() {
        if let genreArray = ConfigurationService.shared.movieGenres {
            var genreNames = genreArray.map{ $0.value }
            genreNames.sort(by: {$0 < $1})
            genres = genreNames
        }

    }
    
    @objc private func sectionSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            tableView.tableHeaderView = nil
            showGenres()
        } else {
            tableView.tableHeaderView = slider
        }
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionSegmentedControl.selectedSegmentIndex == 0 {
            return 3
        } else {
            return genres.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if sectionSegmentedControl.selectedSegmentIndex == 0 {
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GenreCell", for: indexPath)
            cell.textLabel?.text = genres[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
            cell.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.1294117719, blue: 0.1411764771, alpha: 1)
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
