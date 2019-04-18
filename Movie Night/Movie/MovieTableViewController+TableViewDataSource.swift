import UIKit

extension MovieTableViewController {
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
            return 0
        }
        
        switch currentState {
        case .details:
            return presenter.movieTrailers.isEmpty ? 3 : 4
        case .reviews:
            return presenter.movieReviews.isEmpty ? 1 : presenter.movieReviews.count
        case .similar:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch currentState {
        case .details:
            
            let rowIndex = presenter.movieTrailers.isEmpty ? indexPath.row + 1 : indexPath.row

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
                return UITableViewCell()
            }
            
        case .reviews:
            
            return presenter.createCell(self, withIdentifier: .review, in: tableView, forRowAt: indexPath)
            
        case .similar:
            
            return presenter.createCell(self, withIdentifier: .similar, in: tableView, forRowAt: indexPath)
            
        }
        
    }
    
}
