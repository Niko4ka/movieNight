import UIKit

class MoviesTableViewController: UITableViewController, ColorThemeCellObserver {
    
    private enum MoviesTableStates {
        case categories
        case genres
    }

    var moviesCategoriesList: [(name: String, requestType: ListRequest, items: [DatabaseObject])] = [
        (name: MoviesCategoriesListRequest.nowPlayingMovies.rawValue.title, requestType: MoviesCategoriesListRequest.nowPlayingMovies, items: []),
        (name: MoviesCategoriesListRequest.popularMovies.rawValue.title, requestType: MoviesCategoriesListRequest.popularMovies, items: []),
        (name: MoviesCategoriesListRequest.upcomingMovies.rawValue.title, requestType: MoviesCategoriesListRequest.upcomingMovies, items: [])
    ]
    
    var genreSections = [GenreMovies]()
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
    var isDarkTheme: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = sectionSegmentedControl
        configureTableView()
        loadCategoriesData()
        addColorThemeObservers()
        checkCurrentColorTheme()
        
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
    
    private func configureTableView() {
        slider = SliderHeaderView(navigator: navigator)
        tableView.tableHeaderView = slider
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        tableView.sectionFooterHeight = 0
        tableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
        tableView.bounces = false
        tableView.allowsSelection = false
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
        
        if !genres.isEmpty && genreSections.isEmpty {
            for genre in genres {
                Client.shared.loadMoviesWithGenre(genre.id) { (result) in
                    
                    if result.isEmpty {
                        Alert.shared.show(on: self)
                    }
                    
                    let item = GenreMovies.init(name: genre.name, movies: result)
                    self.genreSections.append(item)
                    self.tableView.reloadData()
                }
            }
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
        
        switch currentState {
        case .categories:
            return 1
        case .genres:
            return genreSections.count
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentState {
        case .categories:
            return moviesCategoriesList.count
        case .genres:
            if genreSections[section].expanded {
                return 1
            } else {
                return 0
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
        
        cell.colorDelegate = self
        cell.navigator = navigator

        switch currentState {
        case .categories:
            
            cell.requestType = moviesCategoriesList[indexPath.row].requestType
            cell.data = moviesCategoriesList[indexPath.row].items
            cell.headerTitle.text = moviesCategoriesList[indexPath.row].name
            
        case .genres:
            
            cell.data = genreSections[indexPath.section].movies
            cell.removeHeaderView()
        }
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch currentState {
        case .categories:
            return 0
        case .genres:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if currentState == .genres {
            if genreSections[indexPath.section].expanded {
                return 220
            } else {
                return 0
            }
        }
            
        return 250.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        switch currentState {
        case .categories:
            return 0
        case .genres:
            return 2.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if currentState == .genres {
            let header = ExpandableHeaderView()
            header.setup(genre: genres[section], section: section, delegate: self)
            header.seeAllButton.isHidden = genreSections[section].expanded ? false : true
            return header
        }
        
        return nil
    }
 
}

extension MoviesTableViewController: ExpandableHeaderViewDelegate {
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {

        genreSections[section].expanded = !genreSections[section].expanded
        header.seeAllButton.isHidden = !genreSections[section].expanded

        tableView.beginUpdates()

        if !genreSections[section].expanded  {
            tableView.deleteRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
        } else {
            tableView.insertRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
        }

        tableView.endUpdates()
    }
    
    func showGenreList(genre: (id: Int, name: String)) {
        let request = MovieGenresListRequest(genreName: genre.name, genreId: genre.id)
        navigator?.navigate(to: .list(listRequest: request))
    }
}

// MARK: - ColorThemeObserver

extension MoviesTableViewController {
    
    func darkThemeEnabled() {
        print("Dark theme in MoviesTableViewController")
        tableView.backgroundColor = .darkThemeBackground
        sectionSegmentedControl.tintColor = .lightBlueTint
        isDarkTheme = true
    }
    
    func darkThemeDisabled() {
        print("Light theme in MoviesTableViewController")
        tableView.backgroundColor = .white
        isDarkTheme = false
    }
    
}
