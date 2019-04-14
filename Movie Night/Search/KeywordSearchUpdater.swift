import UIKit

typealias SearchKeyword = String

class KeywordSearchUpdater: NSObject, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        let results = searchController.searchResultsController as! KeywordsViewController
        
        if searchText.count < 3  {
            results.results = []
        } else {
            Client.shared.loadKeywords(key: searchText) { (result) in
                switch result {
                case .success(let keywords):
                    results.results = keywords
                case .error:
                    // TODO: add error case
                    return
                }
            }
        }
    }
}
