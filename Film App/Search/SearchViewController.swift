import UIKit
import Alamofire
import ObjectiveC

class SearchViewController: UIViewController {
    
    lazy var keywordsViewController: KeywordsViewController = {
        let src = KeywordsViewController(style: .plain)
        src.delegate = self
        return src
    }()
    
    let updater = KeywordSearchUpdater()
    
    lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: keywordsViewController)
        
        object_setClass(sc.searchBar, UISearchBarNoCancel.self)
        
        sc.searchResultsUpdater = updater
        sc.delegate = self
        return sc
    }()
    
    lazy var resultsViewController: ResultsTableViewController = {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsTableViewController
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(resultsViewController)
        resultsViewController.view.frame = view.bounds
        resultsViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(resultsViewController.view)
        resultsViewController.didMove(toParent: self)
        
        resultsViewController.view.isHidden = true
    }
    
}

extension SearchViewController: KeywordsViewControllerDelegate {

    func keywordsViewController(_ src: KeywordsViewController, didSelect keyword: SearchKeyword) {
        let searchBar = searchController.searchBar
        UIView.performWithoutAnimation {
            searchController.isActive = false
            
            searchBar.text = keyword
        }
        
        ConfigurationService.client.loadSearchResults(forKey: keyword) { (results) in
            guard searchBar.text == keyword else { return }
            
            let data = [ ("Movies", results.movies),
                         ("tvShows", results.tvShows),
                         ("Persons", results.persons) ]
            
            self.resultsViewController.data = data.filter { !$0.1.isEmpty }
        }
    }
    
}

extension SearchViewController: UISearchControllerDelegate {
    
    func didDismissSearchController(_ searchController: UISearchController) {
        updateVisibility()
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        updateVisibility()
    }
    
    func updateVisibility() {
        let hidden = searchController.isActive || searchController.searchBar.text == ""
        resultsViewController.view.isHidden = hidden
    }
    
}
