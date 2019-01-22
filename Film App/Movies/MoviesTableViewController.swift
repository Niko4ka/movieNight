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

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = sectionSegmentedControl
        
        slider = SliderHeaderView(navigator: navigator)
//        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.tableHeaderView = slider
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1))
        tableView.sectionFooterHeight = 0
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
        
        if !genres.isEmpty && genreSections.isEmpty {
            for genre in genres {
                Client.shared.loadMoviesWithGenre(genre.id) { (result) in
                    let item = GenreMovies.init(name: genre.name, movies: result)
                    self.genreSections.append(item)
                    self.tableView.reloadData()
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
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell", for: indexPath) as! CollectionTableViewCell
        cell.navigator = navigator
        cell.setDarkColorMode()
        
        switch currentState {
        case .categories:
            
            cell.contentView.isHidden = false
            cell.data = moviesCategoriesList[indexPath.row].items
            cell.headerTitle.text = moviesCategoriesList[indexPath.row].name
            
        case .genres:
            
            if genreSections[indexPath.section].expanded {
                cell.contentView.isHidden = false
                cell.data = genreSections[indexPath.section].movies
                cell.removeHeaderView()
            } else {
                cell.contentView.isHidden = true
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
            header.setup(withTitle: genreSections[section].name, section: section, delegate: self)
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
        tableView.reloadRows(at: [IndexPath(row: 0, section: section)], with: .automatic)
        tableView.layoutIfNeeded()
        tableView.endUpdates()
    }
}
