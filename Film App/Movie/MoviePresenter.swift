//
//  MoviePresenter.swift
//  Film App
//
//  Created by Вероника Данилова on 21/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class MoviePresenter: MovieTableViewPresenter {
    
    var castCellConfigured = false
    
    func loadData(_ controller: MovieTableViewController, forMovieId id: Int, andType type: MediaType) {
        
        var detailsUrl: String!
        var castUrl: String!
        var trailersUrl: String!
        var reviewsUrl: String!
        
        if type == .movie {
            detailsUrl = "https://api.themoviedb.org/3/movie/\(id)?api_key=\(ConfigurationService.themoviedbKey)"
            castUrl = "https://api.themoviedb.org/3/movie/\(id)/credits?api_key=\(ConfigurationService.themoviedbKey)"
            trailersUrl = "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=\(ConfigurationService.themoviedbKey)"
            reviewsUrl = "https://api.themoviedb.org/3/movie/\(id)/reviews?api_key=\(ConfigurationService.themoviedbKey)"
        } else {
            detailsUrl = "https://api.themoviedb.org/3/tv/\(id)?api_key=\(ConfigurationService.themoviedbKey)"
            castUrl = "https://api.themoviedb.org/3/tv/\(id)/credits?api_key=\(ConfigurationService.themoviedbKey)"
            trailersUrl = "https://api.themoviedb.org/3/tv/\(id)/videos?api_key=\(ConfigurationService.themoviedbKey)"
            reviewsUrl = "https://api.themoviedb.org/3/tv/\(id)/reviews?api_key=\(ConfigurationService.themoviedbKey)"
        }
        
        AF.request(detailsUrl).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else { return }
            guard let details = MovieDetails(ofType: type, from: json) else { return }
            
            controller.movieDetails = details
            
            self.configureHeaderView(controller, with: details)

            Spinner.stop()
        }
        
        AF.request(castUrl).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else { return }
            guard let cast = MovieCast(ofType: type, from: json) else { return }
            
            controller.movieCast = cast
            controller.tableView.reloadData()
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
                                    controller.movieTrailers.append(trailer)
                                }
                            }
                            
                            trailersLoadingGroup.leave()
                        }
                    })
                    
                }
            }
            
            trailersLoadingGroup.notify(queue: .main) {
                print("Trailers count - \(controller.movieTrailers.count)")
                controller.tableView.reloadData()
            }
        }
        
        AF.request(reviewsUrl).responseJSON { (response) in
            guard let json = response.result.value as? [String: Any],
                let results = json["results"] as? [Dictionary<String, Any>] else {
                    print("reviews error")
                    return
            }
            
            if !results.isEmpty {
                for result in results {
                    if let review = MovieReview(from: result) {
                        controller.movieReviews.append(review)
                    }
                }
            }
            
            
        }
    }

    func createCell(_ controller: MovieTableViewController, withIdentifier identifier: CellIdentifiers, in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {

        
        switch identifier {
        case .trailers:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! TrailersTableViewCell
            
            cell.playVideo = { id in
                
                let storyboard = UIStoryboard(name: "Movie", bundle: nil)
                let videoController = storyboard.instantiateViewController(withIdentifier: "VideoPlayerViewController") as! VideoPlayerViewController
                videoController.videoID = id
                
                videoController.modalTransitionStyle = .crossDissolve
                videoController.modalPresentationStyle = .fullScreen
                controller.present(videoController, animated: true, completion: nil)
            }
            
            if !controller.movieTrailers.isEmpty {
                cell.trailers = controller.movieTrailers
                cell.trailersCollectionView.reloadData()
            }
            return cell
        case .overview:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! OverviewTableViewCell
            if controller.movieDetails != nil {
                cell.configure(with: controller.movieDetails!)
            }
            return cell
        case .cast:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! CastTableViewCell
            if controller.movieCast != nil && !castCellConfigured {
                cell.configure(with: controller.movieCast!)
                castCellConfigured = true
            }
            return cell
        case .information:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! InformationTableViewCell
            if controller.movieDetails != nil {
                cell.configure(with: controller.movieDetails!)
            }
            return cell
        case .review:
            
            if controller.movieReviews.isEmpty {
                let cell = 
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! ReviewTableViewCell
                cell.configure(with: controller.movieReviews[indexPath.row])
                return cell
            }
            
            
            
            
        }
    }
    
    
    private func configureHeaderView(_ controller: MovieTableViewController, with details: MovieDetails) {
        
        if let backdropUrl = details.backdropUrl {
            controller.backdropImageView.kf.setImage(with: backdropUrl)
        } else {
            controller.backdropContentView.removeFromSuperview()
            controller.headerView.translatesAutoresizingMaskIntoConstraints = false
            controller.moviePoster.topAnchor.constraint(equalTo: controller.headerView.topAnchor, constant: 8.0).isActive = true
        }
        
        if let posterUrl = details.posterUrl {
            controller.moviePoster.kf.setImage(with: posterUrl)
        }
        
        controller.titleLabel.text = details.title
        controller.genresLabel.text = details.genres
        
        controller.ratingStackView.setRating(details.rating, from: details.voteCount)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: details.releaseDate) {
            formatter.timeStyle = .none
            formatter.dateStyle = .medium
            controller.releasedLabel.text = "Released: \(formatter.string(from: date))"
        } else {
            controller.releasedLabel.text = "Released: \(details.releaseDate)"
        }
        
        controller.tableView.reloadData()
    }
    
}
