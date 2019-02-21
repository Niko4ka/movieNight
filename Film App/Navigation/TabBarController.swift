import UIKit

class TabBarController: UITabBarController, ColorThemeObserver {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let movies = getMoviesNavigationController()
        movies.tabBarItem = UITabBarItem(title: "Movies", image: UIImage(named: "movies"), tag: 0)
        
        let search = getSearchNavigationController()
        search.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
        let wishlist = getWishlistNavigationController()
        wishlist.tabBarItem = UITabBarItem(title: "Wishlist", image: UIImage(named: "wishlist"), tag: 2)
        
        let map = CinemasMapViewController()
        map.tabBarItem = UITabBarItem(title: "Cinemas", image: UIImage(named: "map"), tag: 3)
        
        let settings = getSettings()
        settings.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settings"), tag: 4)
        
        viewControllers = [movies, search, map, wishlist, settings]
        
        addColorThemeObservers()
    }
    
    private func getMoviesNavigationController() -> UINavigationController {
        let moviesVC = MoviesTableViewController()
        let movies = UINavigationController(rootViewController: moviesVC)
        let moviesNavigator = ProjectNavigator(navigationController: movies)
        moviesVC.navigator = moviesNavigator
        return movies
    }
    
    private func getSearchNavigationController() -> UINavigationController {
        let searchVC = SearchViewController()
        let search = UINavigationController(rootViewController: searchVC)
        let searchNavigator = ProjectNavigator(navigationController: search)
        searchVC.navigator = searchNavigator
        return search
    }
    
    private func getWishlistNavigationController() -> UINavigationController {
        
        let wishlistVC = WishlistViewController()
        let wishlist = UINavigationController(rootViewController: wishlistVC)
        let wishlistNavigator = ProjectNavigator(navigationController: wishlist)
        wishlistVC.navigator = wishlistNavigator
        return wishlist
 
    }
    
    private func getSettings() -> SettingsTableViewController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let settings = storyboard.instantiateViewController(withIdentifier: "SettingsTVC") as! SettingsTableViewController
        return settings
    }
    
    func darkThemeEnabled() {
        self.tabBar.barStyle = .black
        self.tabBar.unselectedItemTintColor = .white
        self.tabBar.tintColor = .lightBlueTint
    }
    
    func darkThemeDisabled() {
        self.tabBar.barStyle = .default
        self.tabBar.unselectedItemTintColor = nil
        self.tabBar.tintColor = .defaultBlueTint
    }

}
