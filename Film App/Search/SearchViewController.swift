import UIKit
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
        return ResultsTableViewController(navigator: navigator)
    }()
    
    var navigator: ProjectNavigator!

    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.white
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let hintLabel = UILabel()
        hintLabel.text = "Start printing keyword to search particular movies, TV shows or persons"
        hintLabel.font = UIFont.systemFont(ofSize: 15.0)
        hintLabel.textColor = #colorLiteral(red: 0.4352941215, green: 0.4431372583, blue: 0.4745098054, alpha: 1)
        hintLabel.textAlignment = .center
        view.addSubview(hintLabel)
        hintLabel.numberOfLines = 0
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -0.15 * view.frame.height).isActive = true
        hintLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 32).isActive = true
        
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
        
        Client.shared.loadSearchResults(forKey: keyword) { (results) in
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
