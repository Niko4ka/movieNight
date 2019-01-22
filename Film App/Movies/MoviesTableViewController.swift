import UIKit

class MoviesTableViewController: UITableViewController {
    
    private enum MoviesTableStates {
        case categories
        case genres
    }

    var moviesCategoriesList: [(name: String, items: [DatabaseObject])] = [
        (name: "Now in cinemas", items: []),
        (name: "Popular", items: []),
        (name: "Upcoming", items: [])
    ]
    
    var genreMovies = [GenreMovies]()
    
    private var currentState: MoviesTableStates = .categories {
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
    
    lazy var genres: [(id: Int, name: String)] = {
        
        var result = [(id: Int, name: String)]()
        if let genreArray = ConfigurationService.shared.movieGenres {
            genreArray.forEach { result.append((id: $0.key, name: $0.value)) }
            result.sort(by: { $0.name < $1.name })
        }
        return result
    }()
    
    var navigator: ProjectNavigator?
    var slider: SliderHeaderView?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = sectionSegmentedControl
        
        slider = SliderHeaderView(navigator: navigator)
        tableView.tableHeaderView = slider
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        tableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
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
            self.moviesCategoriesList[0].items = movies
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        }
        
        Client.shared.loadMoviesCategory(.popular) { (movies) in
            self.moviesCategoriesList[1].items = movies
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        }
        
        Client.shared.loadMoviesCategory(.upcoming) { (movies) in
            self.moviesCategoriesList[2].items = movies
            self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
        }
    }
    
    private func showGenres() {
        
        if !genres.isEmpty {
            for genre in genres {
                Client.shared.loadMoviesWithGenre(genre.id) { (result) in
                    let item = GenreMovies.init(name: genre.name, movies: result)
                    self.genreMovies.append(item)
                }
            }
        } else {
            // TODO: Show alert
        }
        
    }
    
    @objc private func sectionSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            tableView.tableHeaderView = nil
            currentState = .genres
            showGenres()
        } else {
            tableView.tableHeaderView = slider
            currentState = .categories
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentState == .categories {
            return moviesCategoriesList.count
        } else {
            return genreMovies.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
        cell.navigator = navigator
        cell.setDarkColorMode()
        
        switch currentState {
        case .categories:
            
            cell.data = moviesCategoriesList[indexPath.row].items
            cell.headerTitle.text = moviesCategoriesList[indexPath.row].name
            
        case .genres:
            
            cell.data = genreMovies[indexPath.row].movies
            cell.headerTitle.text = genreMovies[indexPath.row].name
        }
        
        return cell

    }
 
}
