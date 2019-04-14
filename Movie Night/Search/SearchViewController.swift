import UIKit
import ObjectiveC

class SearchViewController: UIViewController {
    
    // MARK: - Variables

    lazy var keywordsViewController: KeywordsViewController = {
        let src = KeywordsViewController(style: .plain)
        src.delegate = self
        return src
    }()
    
    let updater = KeywordSearchUpdater()
    
    lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: keywordsViewController)
        
        object_setClass(sc.searchBar, UISearchBarNoCancel.self)
        sc.searchBar.delegate = self
        sc.searchResultsUpdater = updater
        sc.delegate = self
        return sc
    }()
    
    lazy var resultsViewController: ResultsTableViewController = {
        return ResultsTableViewController(navigator: navigator)
    }()
    
    var navigator: ProjectNavigator!
    
    // MARK: - Methods

    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.white
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createHintLabel()
        addResultsViewController()
        setupColorThemeObserver()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let isDarkTheme = UserDefaults.standard.bool(forKey: "isDarkTheme")
        if isDarkTheme {
            return .lightContent
        }
        return .default
    }
    
    /// Creates the hint label to be shown before the user starts printing a keyword
    private func createHintLabel() {
        let hintLabel = UILabel()
        hintLabel.text = "Start printing keyword to search particular movies, TV shows or persons"
        hintLabel.font = UIFont.systemFont(ofSize: 15.0)
        hintLabel.textColor = .lightGray
        hintLabel.textAlignment = .center
        view.addSubview(hintLabel)
        hintLabel.numberOfLines = 0
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hintLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -0.15 * view.frame.height).isActive = true
        hintLabel.widthAnchor.constraint(equalToConstant: view.frame.width - 32).isActive = true
    }
    
    private func addResultsViewController() {
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
        
        Client.shared.loadSearchResults(forKey: keyword) { (result) in
            guard searchBar.text == keyword else { return }
            
            switch result {
            case .success(let results):
                let data = [ ("Movies", results.movies),
                             ("tvShows", results.tvShows),
                             ("Persons", results.persons) ]
                self.resultsViewController.keyword = keyword
                self.resultsViewController.data = data.filter { !$0.1.isEmpty }
            case .error:
                Alert.shared.show(on: self)
            }
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

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchKeyword = searchBar.text {
            keywordsViewController(keywordsViewController, didSelect: searchKeyword)
        }
    }
}

extension SearchViewController: ColorThemeObserver {
    
    func darkThemeEnabled() {
        view.backgroundColor = .darkThemeBackground
        keywordsViewController.tableView.backgroundColor = .darkThemeBackground
        keywordsViewController.isDarkTheme = true
        
        if let textField = getTextFieldOfSearchBar() {
            textField.backgroundColor = UIColor.groupTableViewBackground
        }
    }
    
    func darkThemeDisabled() {
        view.backgroundColor = .white
        keywordsViewController.tableView.backgroundColor = .white
        keywordsViewController.isDarkTheme = false
        
        if let textField = getTextFieldOfSearchBar() {
            textField.backgroundColor = nil
        }
    }
    
    private func getTextFieldOfSearchBar() -> UITextField? {
        
        for subview in searchController.searchBar.subviews {
            for searchView in subview.subviews {
                if searchView.isKind(of: UITextField.self) {
                    return searchView as? UITextField
                }
            }
        }
        return nil
    }
    
}
