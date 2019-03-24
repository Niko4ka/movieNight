import UIKit

struct WishlistPredicates {
    static let tvPredicate = NSPredicate(format: "mediaType.name CONTAINS[cd] 'tv'")
    static let moviePredicate = NSPredicate(format: "mediaType.name CONTAINS[cd] 'movie'")
}

protocol WishlistMainViewProtocol {
    var sectionSegmentedControl: UISegmentedControl { get }
    func configureNavigationBar()
}

class WishlistViewController: UIViewController, ColorThemeCellObserver {
    
    var navigator: ProjectNavigator?
    var isDarkTheme: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        checkCurrentViewMode()
        addWishlistViewObservers()
        setupColorThemeObserver()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if isDarkTheme {
            return .lightContent
        }
        return .default
    }
    
    private func addWishlistViewObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(wishlistViewDidChange(_:)), name: .listWishlistViewSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wishlistViewDidChange(_:)), name: .collectionWishlistViewSelected, object: nil)
    }
    
    private func checkCurrentViewMode() {
        let currentView = UserDefaults.standard.string(forKey: "wishlistView")
        if currentView == "list" {
            showAsTable()
        } else {
            showAsCollection()
        }
    }
    
    @objc func wishlistViewDidChange(_ notification: Notification) {
        if notification.name.rawValue == "listWishlistView" {
            showAsTable()
        } else {
            showAsCollection()
        }
    }

    func showAsTable() {
        
        if let currentScreen = self.children.last as? WishlistCollectionViewController {
            currentScreen.view.removeFromSuperview()
            currentScreen.removeFromParent()
        }
        
        let wishlistTable = WishlistTableViewController()
        wishlistTable.navigator = navigator
        addChild(wishlistTable)
        view.addSubview(wishlistTable.view)
        wishlistTable.didMove(toParent: self)
        wishlistTable.isDarkTheme = isDarkTheme
    }
    
    func showAsCollection() {
        
        if let currentScreen = self.children.last as? WishlistTableViewController {
            currentScreen.view.removeFromSuperview()
            currentScreen.removeFromParent()
        }
        
        let layout = CatalogCollectionViewLayout()
        let wishlistCollection = WishlistCollectionViewController.init(collectionViewLayout: layout)
        wishlistCollection.navigator = navigator
        addChild(wishlistCollection)
        view.addSubview(wishlistCollection.view)
    
        if let navigationController = self.navigationController,
            let tabBarController = self.tabBarController {
            let yOffset = navigationController.navigationBar.frame.maxY
            let height = self.view.frame.height - navigationController.navigationBar.frame.height - tabBarController.tabBar.frame.height
            wishlistCollection.view.frame = CGRect(x: 0, y: yOffset, width: self.view.frame.width, height: height)
        }
        
        wishlistCollection.didMove(toParent: self)
        wishlistCollection.isDarkTheme = isDarkTheme
    }

}

extension WishlistViewController {
    
    func darkThemeEnabled() {
        isDarkTheme = true
        if let child = self.children.last as? ColorThemeCellObserver {
            child.isDarkTheme = isDarkTheme
        }
        if let leftBarButtonItem = navigationItem.leftBarButtonItem {
            leftBarButtonItem.tintColor = .lightBlueTint
        }
    }
    
    func darkThemeDisabled() {
        isDarkTheme = false
        if let child = self.children.last as? ColorThemeCellObserver {
            child.isDarkTheme = isDarkTheme
        }
        if let leftBarButtonItem = navigationItem.leftBarButtonItem {
            leftBarButtonItem.tintColor = .defaultBlueTint
        }
    }
    
}
