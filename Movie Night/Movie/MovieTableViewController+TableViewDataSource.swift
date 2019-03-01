import UIKit

extension MovieTableViewController {
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
            return 0
        }
        
        switch currentState {
        case .details:
            
            if presenter.movieTrailers.isEmpty {
                return 3
            } else {
                return 4
            }
            
        case .reviews:
            
            if presenter.movieReviews.isEmpty {
                return 1
            } else {
                return presenter.movieReviews.count
            }
            
        case .similar:
            
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch currentState {
        case .details:
            
            var rowIndex: Int!
            if presenter.movieTrailers.isEmpty {
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
