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
    
    lazy var genres: [GenreSection] = {
        
        var result = [GenreSection]()
        if let genreArray = ConfigurationService.shared.movieGenres {
            result = genreArray.compactMap { GenreSection(id: $0.key, name: $0.value)}
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
        setupColorThemeObserver()
        setNeedsStatusBarAppearanceUpdate()
        
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isDarkTheme {
            return .lightContent
        }
        return .default
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
        
        Client.shared.loadMoviesCategory(.nowPlaying) { (result) in
            switch result {
            case .success(let movies):
                self.moviesCategoriesList[0].items = movies
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            case .error:
                break
            }
        }
        
        Client.shared.loadMoviesCategory(.popular) { (result) in
            switch result {
            case .success(let movies):
                self.moviesCategoriesList[1].items = movies
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
            case .error:
                break
            }
        }
        
        Client.shared.loadMoviesCategory(.upcoming) { (result) in
            switch result {
            case .success(let movies):
                self.moviesCategoriesList[2].items = movies
                self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
            case .error:
                break
            }
        }
    }
    
    private func loadMoviesForGenreInSection(_ section: Int) {
        
        Client.shared.loadMoviesWithGenre(genres[section].id) { (result) in
            
            switch result {
            case .success(let movies):
                self.genres[section].setMovies(movies)
                UIView.performWithoutAnimation {
                    let indexSet = IndexSet(integer: section)
                    self.tableView.reloadSections(indexSet, with: .none)
                }
            case .error:
                self.showError()
            }
        }
    }
    
    @objc private func sectionSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            tableView.tableHeaderView = nil
            currentState = .genres
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
            if !genres.isEmpty {
                return genres.count
            } else {
                return 0
            }
            
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentState {
        case .categories:
            return moviesCategoriesList.count
        case .genres:
            
            if genres[section].expanded {
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
            cell.headerTitle.text = moviesCategoriesList[indexPath.row].name
            let items = moviesCategoriesList[indexPath.row].items
            if items.isEmpty {
                cell.showActivityIndicator(withHeader: true)
            } else {
                cell.data = items
            }

        case .genres:
            
            if let movies = genres[indexPath.section].movies {
                cell.data = movies
                cell.removeHeaderView()
            } else {
                cell.showActivityIndicator(withHeader: false)
                loadMoviesForGenreInSection(indexPath.section)
            }

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
            if genres[indexPath.section].expanded {
                return 220
            } else {
                return 0
            }
        }
            
        return 250.0
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if currentState == .genres {
            if genres[indexPath.section].expanded {
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
            header.seeAllButton.isHidden = genres[section].expanded ? false : true
            return header
        }
        
        return nil
    }
 
}

extension MoviesTableViewController: ExpandableHeaderViewDelegate {
    
    func toggleSection(header: ExpandableHeaderView, section: Int) {
        
        genres[section].expanded = !genres[section].expanded
        header.seeAllButton.isHidden = !genres[section].expanded
        
        if !genres[section].expanded  {
            tableView.deleteRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
        } else {
            tableView.insertRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()

    }
    
    func showGenreList(genre: GenreSection) {
        let request = MovieGenresListRequest(genreName: genre.name, genreId: genre.id)
        navigator?.navigate(to: .list(listRequest: request))
    }
}

// MARK: - ColorThemeObserver

extension MoviesTableViewController {
    
    func darkThemeEnabled() {
        tableView.backgroundColor = .darkThemeBackground
        sectionSegmentedControl.tintColor = .lightBlueTint
        isDarkTheme = true
    }
    
    func darkThemeDisabled() {
        tableView.backgroundColor = .white
        sectionSegmentedControl.tintColor = .defaultBlueTint
        isDarkTheme = false
    }
    
}
