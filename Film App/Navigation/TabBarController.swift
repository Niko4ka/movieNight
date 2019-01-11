import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let moviesVC = MoviesTableViewController()
        let movies = UINavigationController(rootViewController: moviesVC)
        let moviesNavigator = ProjectNavigator(navigationController: movies)
        moviesVC.navigator = moviesNavigator
        movies.tabBarItem = UITabBarItem(title: "Movies", image: UIImage(named: "movies"), tag: 0)
        
        let searchVC = SearchViewController()
        let search = UINavigationController(rootViewController: searchVC)
        let searchNavigator = ProjectNavigator(navigationController: search)
        searchVC.navigator = searchNavigator
        search.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        
        
        let wishlistVC = WishlistTableViewController()
        let wishlist = UINavigationController(rootViewController: wishlistVC)
        let wishlistNavigator = ProjectNavigator(navigationController: wishlist)
        wishlistVC.navigator = wishlistNavigator
        wishlist.tabBarItem = UITabBarItem(title: "Wishlist", image: UIImage(named: "wishlist"), tag: 2)
        
        viewControllers = [movies, search, wishlist]
    }

}
