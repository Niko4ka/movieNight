//
//  MovieTableViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 17/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

protocol MovieTableViewPresenter: class {

    func loadData(_ controller: MovieTableViewController, forMovieId id: Int, andType type: MediaType)
    
    func createCell(_ controller: MovieTableViewController, withIdentifier identifier: CellIdentifiers, in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell
}

class MovieTableViewController: UITableViewController {
    
    @IBOutlet weak var headerView: UIView!
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
    
    public var mediaType: MediaType!
    public var movieId: Int!
    private var presenter: MovieTableViewPresenter!
    public var movieDetails: MovieDetails?
    public var movieCast: MovieCast?
    public var movieTrailers: [MovieTrailer] = []
    public var movieReviews: [MovieReview] = []
    public var similarMovies: [DatabaseObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MoviePresenter()
        Spinner.start(from: (self.navigationController?.view)!)
        
//        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.tag = 0
        tableView.register(UINib(nibName: "CollectionTableViewCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
        
        guard let id = movieId, let type = mediaType else { return }
        print("ID - \(id)")
        
        switch type {
        case .movie:
            presenter.loadData(self, forMovieId: id, andType: .movie)
        case .tvShow:
            presenter.loadData(self, forMovieId: id, andType: .tvShow)
        default:
            ()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if backdropGradientView != nil && !backdropGradientView.isHidden {
            self.setGradientView()
        }
        self.setAddToWishlistButton()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 1:
            tableView.tag = 1
            tableView.separatorStyle = .singleLine
            tableView.reloadData()
        case 2:
            tableView.tag = 2
            tableView.separatorStyle = .singleLine
            tableView.reloadData()
        default:
            tableView.tag = 0
            tableView.separatorStyle = .singleLine
            tableView.reloadData()
        }
        
    }
    
    @IBAction func addToWishlistButtonPressed(_ sender: Any) {
        
        if addToWishlistButton.isSelected {
            if let selectedMovie = CoreDataManager.shared.findMovie(withID: Int32(movieId)).first {
                CoreDataManager.shared.delete(object: selectedMovie)
                self.addToWishlistButton.isSelected = false
                setAddToWishlistButton()
            }
        } else {
            guard let details = movieDetails, let poster = moviePoster.image else { return }
            
            let currentDateTime = Date()
            CoreDataManager.shared.saveItemToWishlist(mediaType: mediaType.rawValue, data: details, poster: poster, saveDate: currentDateTime)
            self.addToWishlistButton.isSelected = true
            setAddToWishlistButton()
        }

    }
    
    private func setGradientView() {
        let gradientLayer = CAGradientLayer()
        let transparent = UIColor.init(white: 1, alpha: 0)
        let white = UIColor.white
        gradientLayer.frame = self.backdropGradientView.bounds
        gradientLayer.colors =
            [transparent.cgColor, white.cgColor]
        self.backdropGradientView.layer.mask = gradientLayer
    }
    
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
            addToWishlistButton.layer.borderColor = #colorLiteral(red: 0.2039215686, green: 0.4745098039, blue: 0.9647058824, alpha: 1)
            addToWishlistButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
            addToWishlistButton.setTitleColor(#colorLiteral(red: 0.2039215686, green: 0.4745098039, blue: 0.9647058824, alpha: 1), for: .normal)
            addToWishlistButton.setTitle("Add to wishlist", for: .normal)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if tableView.tag == 0 {
            
            if movieTrailers.isEmpty {
                return 3
            } else {
                return 4
            }
            
        } else if tableView.tag == 1 {
            if movieReviews.isEmpty {
                return 1
            } else {
                return movieReviews.count
            }
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            
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
            
        } else if tableView.tag == 1 {
            return presenter.createCell(self, withIdentifier: .review, in: tableView, forRowAt: indexPath)
        } else {
            return presenter.createCell(self, withIdentifier: .similar, in: tableView, forRowAt: indexPath)
        }
    }
    
}
