import UIKit

struct WishlistPredicates {
    static let tvPredicate = NSPredicate(format: "mediaType.name CONTAINS[cd] 'tv'")
    static let moviePredicate = NSPredicate(format: "mediaType.name CONTAINS[cd] 'movie'")
}

class WishlistViewController: UIViewController, ColorThemeObserver {
    
    var navigator: ProjectNavigator?

    override func viewDidLoad() {
        super.viewDidLoad()

        checkCurrentViewMode()
        addWishlistViewObservers()
        addColorThemeObservers()
        checkCurrentColorTheme()
    }
    
    private func addWishlistViewObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(showAsTable), name: .listWishlistViewSelected, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAsCollection), name: .collectionWishlistViewSelected, object: nil)
    }
    
    private func checkCurrentViewMode() {
        let currentView = UserDefaults.standard.string(forKey: "wishlistView")
        if currentView == "list" {
            showAsTable()
        } else {
            showAsCollection()
        }
    }

    @objc func showAsTable() {
        
        if let currentScreen = self.children.last as? WishlistCollectionViewController {
            currentScreen.view.removeFromSuperview()
            currentScreen.removeFromParent()
        }
        
        let wishlistTable = WishlistTableViewController()
        wishlistTable.navigator = navigator
        addChild(wishlistTable)
        view.addSubview(wishlistTable.view)
        wishlistTable.didMove(toParent: self)
    }
    
    @objc func showAsCollection() {
        
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
    }

}

extension WishlistViewController {
    
    func darkThemeEnabled() {
        if var child = self.children.last as? WishlistColorThemeObserver {
            child.isDarkTheme = true
        }
        if let leftBarButtonItem = navigationItem.leftBarButtonItem {
            leftBarButtonItem.tintColor = .lightBlueTint
        }
    }
    
    func darkThemeDisabled() {
        if var child = self.children.last as? WishlistColorThemeObserver {
            child.isDarkTheme = false
        }
        if let leftBarButtonItem = navigationItem.leftBarButtonItem {
            leftBarButtonItem.tintColor = .defaultBlueTint
        }
    }
    
}
