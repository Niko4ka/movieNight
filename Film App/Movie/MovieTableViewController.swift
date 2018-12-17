//
//  MovieTableViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 17/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class MovieTableViewController: UITableViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var backdropGradientView: UIView!
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var releasedLabel: UILabel!
    @IBOutlet weak var addToWishlistButton: UIButton!
    @IBOutlet weak var movieSegmentedControl: UISegmentedControl!
    
    
    public var mediaType: MediaType!
    public var movieId: Int!
    private var movieDetails: MovieDetails?
    private var movieCast: MovieCast?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Spinner.start(from: (self.navigationController?.view)!)
        
        self.tableView.tableHeaderView = headerView
        
        guard let id = movieId, let type = mediaType else { return }
        
        switch type {
        case .movie:
            print("Movie")
            loadData(forMovieId: id, andType: .movie)
        case .tvShow:
            print("TV")
            loadData(forMovieId: id, andType: .tvShow)
        default:
            ()
        }
        

    }
    
    private func loadData(forMovieId id: Int, andType type: MediaType) {
        
        var detailsUrl: String!
        var castUrl: String!
        
        if type == .movie {
            detailsUrl = "https://api.themoviedb.org/3/movie/\(id)?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US"
            castUrl = "https://api.themoviedb.org/3/movie/\(id)/credits?api_key=81c0943d1596e1cc2b1c8de9e9ba8945"
        } else {
            detailsUrl = "https://api.themoviedb.org/3/tv/\(id)?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US"
            castUrl = "https://api.themoviedb.org/3/tv/\(id)/credits?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US"
        }
        
        AF.request(detailsUrl).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else { return }
            guard let details = MovieDetails(ofType: type, from: json) else { return }
            
            self.movieDetails = details
            
            if let backdropUrl = details.backdropUrl {
                self.backdropImageView.kf.setImage(with: backdropUrl)
            }
            
            if let posterUrl = details.posterUrl {
                self.moviePoster.kf.setImage(with: posterUrl)
            }
            
            self.titleLabel.text = details.title
            self.genresLabel.text = details.genres
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: details.releaseDate) {
                formatter.timeStyle = .none
                formatter.dateStyle = .medium
                self.releasedLabel.text = "Released: \(formatter.string(from: date))"
            } else {
                self.releasedLabel.text = "Released: \(details.releaseDate)"
            }
            
            self.tableView.reloadData()
            
            Spinner.stop()
        }
        
        AF.request(castUrl).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else { return }
            guard let cast = MovieCast(ofType: type, from: json) else { return }
            
            self.movieCast = cast
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Trailers", for: indexPath) as! TrailersTableViewCell
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Overview", for: indexPath) as! OverviewTableViewCell
            if movieDetails != nil {
                cell.configure(with: movieDetails!)
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cast", for: indexPath) as! CastTableViewCell
            if movieCast != nil {
                cell.configure(with: movieCast!)
            }
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Information", for: indexPath) as! InformationTableViewCell
            if movieDetails != nil {
                cell.configure(with: movieDetails!)
            }
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
        
 
    }
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = tableView.tableHeaderView as!
//    }
    

}
