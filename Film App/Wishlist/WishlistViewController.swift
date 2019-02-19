import UIKit

struct WishlistPredicates {
    static let tvPredicate = NSPredicate(format: "mediaType.name CONTAINS[cd] 'tv'")
    static let moviePredicate = NSPredicate(format: "mediaType.name CONTAINS[cd] 'movie'")
}

class WishlistViewController: UIViewController {
    
    var navigator: ProjectNavigator?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Mode", style: .plain, target: self, action: #selector(selectViewMode))
        showAsCollection()
    }
    
    @objc func selectViewMode() {
        
        let sheet = UIAlertController(title: "Select prefered view mode", message: nil, preferredStyle: .actionSheet)
        
        let tableMode = UIAlertAction(title: "List", style: .default) { _ in
            guard let currentScreen = self.children.last as? WishlistCollectionViewController else { return }
            currentScreen.view.removeFromSuperview()
            currentScreen.removeFromParent()
            self.showAsTable()
        }
        
        let collectionMode = UIAlertAction(title: "Collection", style: .default) { _ in
            guard let currentScreen = self.children.last as? WishlistTableViewController else { return }
            currentScreen.view.removeFromSuperview()
            currentScreen.removeFromParent()
            self.showAsCollection()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        sheet.addAction(tableMode)
        sheet.addAction(collectionMode)
        sheet.addAction(cancel)
        present(sheet, animated: true, completion: nil)
    }

    private func showAsTable() {
        let wishlistTable = WishlistTableViewController()
        wishlistTable.navigator = navigator
        addChild(wishlistTable)
        view.addSubview(wishlistTable.view)
        wishlistTable.didMove(toParent: self)
    }
    
    private func showAsCollection() {
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
