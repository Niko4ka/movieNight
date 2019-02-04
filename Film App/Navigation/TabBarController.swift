import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.tabBar.barStyle = .black
        
        let movies = getMoviesNavigationController()
        movies.tabBarItem = UITabBarItem(title: "Movies", image: UIImage(named: "movies"), tag: 0)
        
        let search = getSearchNavigationController()
        search.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
        let wishlist = getWishlistNavigationController()
        wishlist.tabBarItem = UITabBarItem(title: "Wishlist", image: UIImage(named: "wishlist"), tag: 2)
        
        let map = CinemasMapViewController()
        map.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 3)
        // TODO: Сделать кастомную картиночку
        
        viewControllers = [movies, search, map, wishlist]
    }
    
    private func getMoviesNavigationController() -> UINavigationController {
        let moviesVC = MoviesTableViewController()
        let movies = UINavigationController(rootViewController: moviesVC)
        let moviesNavigator = ProjectNavigator(navigationController: movies, isDarkMode: true)
        moviesVC.navigator = moviesNavigator
        return movies
    }
    
    private func getSearchNavigationController() -> UINavigationController {
        let searchVC = SearchViewController()
        let search = UINavigationController(rootViewController: searchVC)
        let searchNavigator = ProjectNavigator(navigationController: search, isDarkMode: false)
        searchVC.navigator = searchNavigator
        return search
    }
    
    private func getWishlistNavigationController() -> UINavigationController {
        let wishlistVC = WishlistTableViewController()
        let wishlist = UINavigationController(rootViewController: wishlistVC)
        let wishlistNavigator = ProjectNavigator(navigationController: wishlist, isDarkMode: false)
        wishlistVC.navigator = wishlistNavigator
        return wishlist
    }

}

extension TabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if viewController == tabBarController.viewControllers?.first {
            self.tabBar.barStyle = .black
        } else {
            self.tabBar.barStyle = .default
        }
        
    }
    
}
