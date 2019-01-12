import UIKit
import Alamofire
import Kingfisher

class MoviePresenter: MovieTableViewPresenter {
    
    var castCellConfigured = false
    var mediaType: MediaType!
    
    func loadData(_ controller: MovieTableViewController, forMovieId id: Int, andType type: MediaType) {
        
        mediaType = type

        controller.isLoading = true
        
        ConfigurationService.client.loadMovieDetails(forId: id, andType: type) { (details) in
            guard let details = details else {
                
                // TODO: Show alert and pop controller
                controller.isLoading = false
                return
            }
            controller.movieDetails = details
            self.configureHeaderView(controller, with: details)
            controller.isLoading = false
        }
        
        ConfigurationService.client.loadMovieCast(forId: id, andType: type) { (cast) in
            if let cast = cast {
                controller.movieCast = cast
                controller.tableView.reloadData()
            }
        }
        
        ConfigurationService.client.loadMovieTrailers(forId: id, andType: type) { (trailers) in
            controller.movieTrailers = trailers
            controller.tableView.reloadData()
        }
        
        ConfigurationService.client.loadMovieReviews(forId: id, andType: type) { (reviews) in
            controller.movieReviews = reviews
        }
        
        ConfigurationService.client.loadSimilarMovies(forId: id, andType: type) { (similar) in
            controller.similarMovies = similar
        }

    }

    func createCell(_ controller: MovieTableViewController, withIdentifier identifier: CellIdentifiers, in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {

        switch identifier {
            
        case .trailers:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! TrailersTableViewCell
            cell.coordinator = controller
                        
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
            cell.coordinator = controller
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
                cell.coordinator = controller
                cell.headerTitle.text = "Similar"
                cell.data = controller.similarMovies
    
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
