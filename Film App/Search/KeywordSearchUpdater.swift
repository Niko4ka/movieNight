import UIKit

typealias SearchKeyword = String

class KeywordSearchUpdater: NSObject, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        let results = searchController.searchResultsController as! KeywordsViewController
        
        if searchText.count < 3  {
            results.results = []
        } else {
            ConfigurationService.client.loadKeywords(key: searchText) { (keywords) in
                results.results = keywords
            }
        }
    }
    
}
