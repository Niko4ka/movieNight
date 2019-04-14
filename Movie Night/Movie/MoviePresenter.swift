import UIKit
import Alamofire
import Kingfisher

class MoviePresenter: MovieTableViewPresenter {
    
    var castCellConfigured = false
    var movieDetails: MovieDetails?
    var movieCast: MovieCast?
    var movieTrailers: [MovieTrailer] = []
    var movieReviews: [MovieReview] = []
    var similarMovies: [DatabaseObject] = []
    
    func loadData(_ controller: MovieTableViewController, forMovieId id: Int, andType type: MediaType) {
        
        controller.isLoading = true
        
        Client.shared.loadMovieDetails(forId: id, andType: type) { (result) in
            
            switch result {
            case .success(let details):
                self.movieDetails = details
                self.configureHeaderView(controller, with: details)
                controller.isLoading = false
            case .error:
                controller.isLoading = false
                Alert.shared.show(on: controller, withMessage: nil, completion: {
                    controller.navigator?.pop()
                })
                return
            }
        }
        
        Client.shared.loadMovieCast(forId: id, andType: type) { (result) in
            switch result {
            case .success(let cast):
                self.movieCast = cast
                controller.tableView.reloadData()
            case .error:
                break
            }
        }
        
        Client.shared.loadMovieTrailers(forId: id, andType: type) { (result) in
            switch result {
            case .success(let trailers):
                self.movieTrailers = trailers
                controller.tableView.reloadData()
            case .error:
                break
            }
        }
        
        Client.shared.loadMovieReviews(forId: id, andType: type) { (result) in
            switch result {
            case .success(let reviews):
                self.movieReviews = reviews
            case .error:
                break
            }
        }
        
        Client.shared.loadSimilarMovies(forId: id, andType: type) { (result) in
            switch result {
            case .success(let similar):
                self.similarMovies = similar
            case .error:
                break
            }
        }

    }

    func createCell(_ controller: MovieTableViewController, withIdentifier identifier: CellIdentifiers, in tableView: UITableView, forRowAt indexPath: IndexPath) -> UITableViewCell {

        switch identifier {
            
        case .trailers:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! TrailersTableViewCell
            cell.videoPlayer = controller
            cell.colorDelegate = controller
                        
            if !movieTrailers.isEmpty {
                cell.trailers = movieTrailers
                cell.trailersCollectionView.reloadData()
            }
            return cell
            
        case .overview:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! OverviewTableViewCell
            cell.colorDelegate = controller
            if movieDetails != nil {
                cell.configure(with: movieDetails!)
            }
            return cell
            
        case .cast:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! CastTableViewCell
            cell.navigator = controller.navigator
            if movieCast != nil && !castCellConfigured {
                cell.configure(with: movieCast!)
                castCellConfigured = true
            }
            cell.colorDelegate = controller
            return cell
            
        case .information:
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! InformationTableViewCell
            if movieDetails != nil {
                cell.configure(with: movieDetails!)
            }
            cell.colorDelegate = controller
            return cell
            
        case .review:
            if movieReviews.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Empty") as! EmptyTableViewCell
                cell.infoLabel.text = "\"\(controller.titleLabel.text ?? "This \(controller.mediaType.rawValue)")\" hasn't any reviews yet"
                controller.tableView.separatorStyle = .none
                cell.colorDelegate = controller
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier.rawValue, for: indexPath) as! ReviewTableViewCell
                cell.configure(with: movieReviews[indexPath.row])
                cell.colorDelegate = controller
                return cell
            }
            
        case .similar:
            if similarMovies.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Empty") as! EmptyTableViewCell
                cell.infoLabel.text = "\"\(controller.titleLabel.text ?? "This \(controller.mediaType.rawValue)")\" has no similar movies"
                controller.tableView.separatorStyle = .none
                cell.colorDelegate = controller
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell") as! CollectionTableViewCell
                cell.navigator = controller.navigator
                cell.headerTitle.text = "Similar"
                cell.data = similarMovies
                if let details = movieDetails {
                    if controller.mediaType == .movie {
                        cell.requestType = SimilarListRequest.movie(name: details.title, id: controller.movieId)
                    } else {
                        cell.requestType = SimilarListRequest.tv(name: details.title, id: controller.movieId)
                    }
                }
                cell.colorDelegate = controller
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
