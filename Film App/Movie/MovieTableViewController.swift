import UIKit

protocol MovieTableViewPresenter: class {
    /// Loads Movie data to present in controller (details, trailers, similar movies, etc.)
    ///
    /// - Parameters:
    ///   - controller: MovieTableViewController
    ///   - id: movie or TV Show id
    ///   - type: mediatype (.movie or .tvShow)
    func loadData(_ controller: MovieTableViewController, forMovieId id: Int, andType type: MediaType)
    
    /// Returns cell with particular identifier
    ///
    /// - Parameters:
    ///   - controller: MovieTableViewController
    ///   - identifier: cell identifier from CellIdentifiers enum
    ///   - tableView: current tableView
    ///   - indexPath: current indexPath
    /// - Returns: configured cell
    func createCell(_ controller: MovieTableViewController, withIdentifier identifier: CellIdentifiers, in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell
}

protocol VideoPlayerDelegate: class {
    func playVideo(withId id: String)
}

class MovieTableViewController: UITableViewController, ColorThemeCellObserver {

    // MARK: - Outlets
    
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var backdropContentView: UIView!
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var backdropGradientView: UIView!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var ratingStackView: RatingControl!
    @IBOutlet weak var releasedLabel: UILabel!
    @IBOutlet weak var addToWishlistButton: UIButton!
    @IBOutlet weak var movieSegmentedControl: UISegmentedControl!
    
    // MARK: - Variables
    
    public var mediaType: MediaType!
    public var movieId: Int!
    private var presenter: MovieTableViewPresenter!
    public var movieDetails: MovieDetails?
    public var movieCast: MovieCast?
    public var movieTrailers: [MovieTrailer] = []
    public var movieReviews: [MovieReview] = []
    public var similarMovies: [DatabaseObject] = []
    private var currentState: TableStates = .details
    private var gradientLayerIsSet = false

    enum TableStates {
        case details
        case reviews
        case similar
    }

    var navigator: ProjectNavigator?
    
    var isDarkTheme: Bool = false {
        didSet {
            setHeaderColorTheme()
            tableView.reloadData()
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            updateLoading()
        }
    }

    private func updateLoading() {
        if isLoading {
            let activity = UIActivityIndicatorView(style: .gray)
            activity.startAnimating()
            
            tableView.backgroundView = activity
            tableView.tableHeaderView = nil
        } else {
            tableView.backgroundView = nil
            tableView.tableHeaderView = headerView
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Controller Livecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        addColorThemeObservers()
        checkCurrentColorTheme()
        
        guard let id = movieId, let type = mediaType else { return }
        switch type {
        case .movie:
            presenter.loadData(self, forMovieId: id, andType: .movie)
        case .tvShow:
            presenter.loadData(self, forMovieId: id, andType: .tvShow)
        default:
            break
        }
    }
    
    private func configureTableView() {
        updateLoading()
        presenter = MoviePresenter()
        
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
        tableView.register(UINib(nibName: "TrailersTableViewCell", bundle: nil), forCellReuseIdentifier: "Trailers")
        tableView.register(UINib(nibName: "OverviewTableViewCell", bundle: nil), forCellReuseIdentifier: "Overview")
        tableView.register(UINib(nibName: "CastTableViewCell", bundle: nil), forCellReuseIdentifier: "Cast")
        tableView.register(UINib(nibName: "InformationTableViewCell", bundle: nil), forCellReuseIdentifier: "Information")
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "Review")
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if backdropGradientView != nil && !backdropGradientView.isHidden && !gradientLayerIsSet {
            setGradientView()
        }
        self.setAddToWishlistButton()
    }
    
    // MARK: - IBAction functions
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 1:
            currentState = .reviews
            tableView.separatorStyle = .singleLine
            tableView.reloadData()
        case 2:
            currentState = .similar
            tableView.separatorStyle = .singleLine
            tableView.reloadData()
        default:
            currentState = .details
            tableView.separatorStyle = .singleLine
            tableView.reloadData()
        }
        
    }
    
    @IBAction func addToWishlistButtonPressed(_ sender: Any) {
        
        if addToWishlistButton.isSelected {
            if let selectedMovie = CoreDataManager.shared.findMovie(withID: Int32(movieId)).first {
                CoreDataManager.shared.delete(object: selectedMovie)
                self.addToWishlistButton.isSelected = false
                
                if let movieTitle = movieDetails?.title {
                    let toastText = "\"\(movieTitle)\" was removed from wishlist"
                    navigator?.showToast(withText: toastText)
                } else {
                    let toastText = "This movie was removed from wishlist"
                    navigator?.showToast(withText: toastText)
                }
                
                setAddToWishlistButton()
            }
        } else {
            guard let details = movieDetails, let poster = moviePoster.image else { return }
            let backdropImage = backdropImageView.image
            
            let currentDateTime = Date()
            CoreDataManager.shared.saveItemToWishlist(mediaType: mediaType.rawValue, data: details, poster: poster, backdrop: backdropImage, saveDate: currentDateTime)
            self.addToWishlistButton.isSelected = true
            
            if let movieTitle = movieDetails?.title {
                let toastText = "\"\(movieTitle)\" was added to wishlist"
                navigator?.showToast(withText: toastText)
            } else {
                let toastText = "This movie was added to wishlist"
                navigator?.showToast(withText: toastText)
            }

            setAddToWishlistButton()
        }

    }
    
    // MARK: - Private
    
    /// Adds gradient to backdropGradientView
    private func setGradientView() {

        let mainColor: UIColor = .white
        let transparent = UIColor.init(white: 1, alpha: 0)
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.frame = self.backdropGradientView.bounds
        gradientLayer.colors = [transparent.cgColor, mainColor.cgColor]
        self.backdropGradientView.layer.mask = gradientLayer
        
        if !gradientLayerIsSet { gradientLayerIsSet = true }
    }
    
    /// Sets style for selected/deselected addToWishlistButton
    private func setAddToWishlistButton() {
        if addToWishlistButton.isSelected {
            addToWishlistButton.tintColor = UIColor.clear
            addToWishlistButton.setTitleColor(UIColor.lightGray, for: .selected)
            addToWishlistButton.titleLabel?.font = UIFont.systemFont(ofSize: 11.0)
            addToWishlistButton.setTitle("Remove from wishlist", for: .selected)
            addToWishlistButton.layer.borderColor = UIColor.lightGray.cgColor
            addToWishlistButton.layer.borderWidth = 1.0
        } else {
            addToWishlistButton.layer.cornerRadius = 5.0
            addToWishlistButton.layer.borderWidth = 1.0
            addToWishlistButton.layer.borderColor = UIColor.defaultBlueTint.cgColor
            addToWishlistButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
            addToWishlistButton.setTitleColor(.defaultBlueTint, for: .normal)
            addToWishlistButton.setTitle("Add to wishlist", for: .normal)
        }
    }
    
    private func setHeaderColorTheme() {
     
        let starsLabel = getRatingStackViewLabel()
        
        if isDarkTheme {
            headerView.backgroundColor = .darkThemeBackground
            backdropGradientView.backgroundColor = .darkThemeBackground
            titleLabel.textColor = .white
            genresLabel.textColor = .lightText
            releasedLabel.textColor = .lightText
            starsLabel?.textColor = .lightText
            movieSegmentedControl.tintColor = .lightGray
        } else {
            headerView.backgroundColor = .white
            backdropGradientView.backgroundColor = .white
            titleLabel.textColor = .darkText
            genresLabel.textColor = .darkGray
            releasedLabel.textColor = .darkGray
            starsLabel?.textColor = .darkGray
            movieSegmentedControl.tintColor = .darkGray
        }
    }
    
    private func getRatingStackViewLabel() -> UILabel? {
        
        for view in ratingStackView.subviews {
            if view.restorationIdentifier == "starsLabel" {
                return view as? UILabel
            }
        }
        
        return nil
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
            return 0
        }

        switch currentState {
        case .details:
            
            if movieTrailers.isEmpty {
                return 3
            } else {
                return 4
            }
            
        case .reviews:
            
            if movieReviews.isEmpty {
                return 1
            } else {
                return movieReviews.count
            }
            
        case .similar:
            
            return 1
        }
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch currentState {
        case .details:
            
            var rowIndex: Int!
            if movieTrailers.isEmpty {
                rowIndex = indexPath.row + 1
            } else {
                rowIndex = indexPath.row
            }
            
            switch rowIndex {
            case 0:
                return presenter.createCell(self, withIdentifier: .trailers, in: tableView, forRowAt: indexPath)
            case 1:
                return presenter.createCell(self, withIdentifier: .overview, in: tableView, forRowAt: indexPath)
            case 2:
                return presenter.createCell(self, withIdentifier: .cast, in: tableView, forRowAt: indexPath)
            case 3:
                return presenter.createCell(self, withIdentifier: .information, in: tableView, forRowAt: indexPath)
            default:
                let cell = UITableViewCell()
                return cell
            }
            
        case .reviews:
            
            return presenter.createCell(self, withIdentifier: .review, in: tableView, forRowAt: indexPath)
            
        case .similar:
            
            return presenter.createCell(self, withIdentifier: .similar, in: tableView, forRowAt: indexPath)
            
        }

    }
    
}

// MARK: - VideoPlayerDelegate

extension MovieTableViewController: VideoPlayerDelegate {
    
    func playVideo(withId id: String) {
        
        let storyboard = UIStoryboard(name: "Movie", bundle: nil)
        let videoController = storyboard.instantiateViewController(withIdentifier: "VideoPlayerViewController") as! VideoPlayerViewController
        videoController.videoID = id
        
        videoController.modalTransitionStyle = .crossDissolve
        videoController.modalPresentationStyle = .fullScreen
        present(videoController, animated: true, completion: nil)
    }
    
}

extension MovieTableViewController {
    
    func darkThemeEnabled() {
        tableView.backgroundColor = .darkThemeBackground
        isDarkTheme = true
    }
    
    func darkThemeDisabled() {
        tableView.backgroundColor = .white
        isDarkTheme = false
    }
    
}
