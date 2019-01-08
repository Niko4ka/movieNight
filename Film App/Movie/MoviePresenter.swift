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
    var mediaType: MediaType!
    
    func loadData(_ controller: MovieTableViewController, forMovieId id: Int, andType type: MediaType) {
        
        var detailsUrl: String!
        var castUrl: String!
        var trailersUrl: String!
        var reviewsUrl: String!
        var similarUrl: String!
        
        if type == .movie {
            detailsUrl = "https://api.themoviedb.org/3/movie/\(id)?api_key=\(ConfigurationService.themoviedbKey)"
            castUrl = "https://api.themoviedb.org/3/movie/\(id)/credits?api_key=\(ConfigurationService.themoviedbKey)"
            trailersUrl = "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=\(ConfigurationService.themoviedbKey)"
            reviewsUrl = "https://api.themoviedb.org/3/movie/\(id)/reviews?api_key=\(ConfigurationService.themoviedbKey)"
            similarUrl = "https://api.themoviedb.org/3/movie/\(id)/similar?api_key=\(ConfigurationService.themoviedbKey)"
            mediaType = .movie
        } else {
            detailsUrl = "https://api.themoviedb.org/3/tv/\(id)?api_key=\(ConfigurationService.themoviedbKey)"
            castUrl = "https://api.themoviedb.org/3/tv/\(id)/credits?api_key=\(ConfigurationService.themoviedbKey)"
            trailersUrl = "https://api.themoviedb.org/3/tv/\(id)/videos?api_key=\(ConfigurationService.themoviedbKey)"
            reviewsUrl = "https://api.themoviedb.org/3/tv/\(id)/reviews?api_key=\(ConfigurationService.themoviedbKey)"
            similarUrl = "https://api.themoviedb.org/3/tv/\(id)/similar?api_key=\(ConfigurationService.themoviedbKey)"
            mediaType = .tvShow
        }
        
        controller.isLoading = true
        
        AF.request(detailsUrl).responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else { return }
            guard let details = MovieDetails(ofType: type, from: json) else {
                print("details error")
                return }
            
            controller.movieDetails = details

            self.configureHeaderView(controller, with: details)

            controller.isLoading = false
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
        
        AF.request(similarUrl).responseJSON { (response) in
            guard let json = response.result.value as? [String: Any],
                let results = json["results"] as? [Dictionary<String, Any>] else {
                    print("similar error")
                    return
            }
            
            for result in results {
                if let item = DatabaseObject(ofType: type, fromJson: result) {
                    controller.similarMovies.append(item)
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
                cell.showPersonProfile = { id in
                    
                    let storyboard = UIStoryboard(name: "Person", bundle: nil)
                    let personController = storyboard.instantiateViewController(withIdentifier: "PersonTableViewController") as! PersonTableViewController
                    personController.personId = id
                    
                    controller.navigationController?.pushViewController(personController, animated: true)
                    
                }
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "Empty") as! EmptyTableViewCell
                cell.infoLabel.text = "\"\(controller.titleLabel.text ?? "This \(mediaType.rawValue)")\" hasn't any reviews yet"
                controller.tableView.separatorStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! ReviewTableViewCell
                cell.configure(with: controller.movieReviews[indexPath.row])
                return cell
            }
            
        case .similar:
            if controller.similarMovies.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Empty") as! EmptyTableViewCell
                cell.infoLabel.text = "\"\(controller.titleLabel.text ?? "This \(mediaType.rawValue)")\" has no similar movies"
                controller.tableView.separatorStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell") as! CollectionTableViewCell
                
                cell.headerTitle.text = "Similar"
                cell.data = controller.similarMovies
                
                cell.pushController = { id, type, genres in
                    
                    let storyboard = UIStoryboard(name: "Movie", bundle: nil)
                    guard let movieController = storyboard.instantiateViewController(withIdentifier: "MovieTableViewController") as? MovieTableViewController else {
                        return
                    }
                    
                    movieController.movieId = id
                    movieController.mediaType = type
                    controller.navigationController?.pushViewController(movieController, animated: true)
                }
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
            controller.headerView.widthAnchor.constraint(equalToConstant: controller.tableView.frame.width).isActive = true
            controller.moviePoster.topAnchor.constraint(equalTo: controller.headerView.topAnchor, constant: 8.0).isActive = true
        }
        
        if let posterUrl = details.posterUrl {
            controller.moviePoster.kf.setImage(with: posterUrl)
        } else {
            controller.moviePoster.image = UIImage(named: "noPoster")
        }
        
        controller.titleLabel.text = details.title
        controller.navigationItem.title = details.title
        controller.genresLabel.text = details.genres
        
        controller.ratingStackView.setRating(details.rating, from: details.voteCount)
        controller.releasedLabel.text = "Released: \(details.releaseDate)"
        
        let existingMovie = CoreDataManager.shared.findMovie(withID: Int32(details.id))
        if !existingMovie.isEmpty {
            controller.addToWishlistButton.isSelected = true
            controller.viewDidLayoutSubviews()
        }
        

        controller.tableView.tableHeaderView = controller.headerView
        controller.tableView.reloadData()
    }
    
}
