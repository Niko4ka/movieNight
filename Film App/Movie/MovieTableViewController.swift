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
import AVFoundation
import AVKit
import MediaPlayer
import AudioToolbox
//import XCDYouTubeKit

class MovieTableViewController: UITableViewController {
    
    @IBOutlet weak var headerView: UIView!
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
    private var movieDetails: MovieDetails?
    private var movieCast: MovieCast?
    private var movieTrailers: [MovieTrailer] = []

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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !backdropGradientView.isHidden {
            self.setGradientView()
        }
    }
    
    private func loadData(forMovieId id: Int, andType type: MediaType) {
        
        var detailsUrl: String!
        var castUrl: String!
        var trailersUrl: String!
        
        if type == .movie {
            detailsUrl = "https://api.themoviedb.org/3/movie/\(id)?api_key=\(ConfigurationService.themoviedbKey)"
            castUrl = "https://api.themoviedb.org/3/movie/\(id)/credits?api_key=\(ConfigurationService.themoviedbKey)"
            trailersUrl = "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=\(ConfigurationService.themoviedbKey)"
        } else {
            detailsUrl = "https://api.themoviedb.org/3/tv/\(id)?api_key=\(ConfigurationService.themoviedbKey)"
            castUrl = "https://api.themoviedb.org/3/tv/\(id)/credits?api_key=\(ConfigurationService.themoviedbKey)"
            trailersUrl = "https://api.themoviedb.org/3/tv/\(id)/videos?api_key=\(ConfigurationService.themoviedbKey)"
        }
        
        AF.request(detailsUrl).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else { return }
            guard let details = MovieDetails(ofType: type, from: json) else { return }
            
            self.movieDetails = details
            
            if let backdropUrl = details.backdropUrl {
                self.backdropImageView.kf.setImage(with: backdropUrl)
            } else {
                self.backdropImageView.isHidden = true
                self.backdropGradientView.isHidden = true
            }
            
            if let posterUrl = details.posterUrl {
                self.moviePoster.kf.setImage(with: posterUrl)
            }
            
            self.titleLabel.text = details.title
            self.genresLabel.text = details.genres
            
            self.ratingStackView.setRating(details.rating, from: details.voteCount)
            
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
        
        AF.request(trailersUrl).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let results = json["results"] as? [Dictionary<String, Any>] else {
                    print("trailers error")
                    return
            }
            
            let trailersLoadingGroup = DispatchGroup()
            
            for video in results {
                
                trailersLoadingGroup.enter()
                
                    if let youtubeId = video["key"] as? String {
                        AF.request("https://www.googleapis.com/youtube/v3/videos?part=snippet%2CcontentDetails&id=\(youtubeId)&key=\(ConfigurationService.googleKey)").responseJSON(completionHandler: { (response) in
                            
                            if let json = response.result.value as? [String: Any],
                                let items = json["items"] as? [[String: Any]] {
                                
                                if !items.isEmpty {
                                    if let trailer = MovieTrailer(from: items[0]) {
                                        self.movieTrailers.append(trailer)
                                    }
                                }

                                trailersLoadingGroup.leave()
                            }
                        })
                        
                    }
            }
            
            trailersLoadingGroup.notify(queue: .main) {
                print("Trailers count - \(self.movieTrailers.count)")
                self.tableView.reloadData()
            }
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if movieTrailers.isEmpty {
           return 3
        } else {
            return 4
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var rowIndex: Int!
        if movieTrailers.isEmpty {
            rowIndex = indexPath.row + 1
        } else {
            rowIndex = indexPath.row
        }
        
        switch rowIndex {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Trailers", for: indexPath) as! TrailersTableViewCell
            
            cell.playVideo = { id in

//                let playerViewController = AVPlayerViewController()
//                self.present(playerViewController, animated: true)
//                XCDYouTubeClient.default().getVideoWithIdentifier(id, completionHandler: {
//                    [weak playerViewController] (video, error) in
//                    if let streamURLs = video?.streamURLs,
//                        let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[XCDYouTubeVideoQuality.HD720] ?? streamURLs[XCDYouTubeVideoQuality.medium360] ?? streamURLs[XCDYouTubeVideoQuality.small240]) {
//                        playerViewController?.player = AVPlayer(url: streamURL)
//                    } else {
//                        playerViewController?.dismiss(animated: true, completion: nil)
//                    }
//                })
                
            }
            
            if !movieTrailers.isEmpty {
                cell.trailers = movieTrailers
                cell.trailersCollectionView.reloadData()
            }
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
