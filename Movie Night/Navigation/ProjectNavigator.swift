import UIKit

protocol Navigator: class {
    
    associatedtype Destination
    
    init(navigationController: UINavigationController)
    func navigate(to destination: Destination)
}

class ProjectNavigator: Navigator, ColorThemeObserver {

    
    enum Destination {
        case movie(id: Int, type: MediaType)
        case person(id: Int)
        case movieColletion(id: Int)
        case list(listRequest: ListRequest)
    }
    
    private weak var navigation: UINavigationController!
    
    required init(navigationController: UINavigationController) {
        self.navigation = navigationController
        
        NotificationCenter.default.addObserver(self, selector: #selector(ColorThemeObserver.darkThemeEnabled), name: .darkThemeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ColorThemeObserver.darkThemeDisabled), name: .darkThemeDisabled, object: nil)
        
    }
    
    func navigate(to destination: Destination) {
        guard let viewController = makeViewController(for: destination) else { return }
        navigation?.pushViewController(viewController, animated: true)
        
    }
    
    func pop() {
        navigation.popViewController(animated: true)
    }
    
    /// Shows Android-like toast view with some label
    ///
    /// - Parameter text: text of the label
    func showToast(withText text: String) {
        
        if let toast = navigation.view.subviews.last, toast.restorationIdentifier == "toastView" {
            toast.removeFromSuperview()
        }
        navigation.view.showToast(withText: text)
    }
    
    private func makeViewController(for destination: Destination) -> UIViewController? {
        switch destination {
            
        case .movie(let id, let type):
            let storyboard = UIStoryboard(name: "Movie", bundle: nil)
            guard let movieController = storyboard.instantiateViewController(withIdentifier: "MovieTableViewController") as? MovieTableViewController else { return nil }
            movieController.movieId = id
            movieController.mediaType = type
            movieController.navigator = self
            return movieController
            
        case .person(let id):
            let storyboard = UIStoryboard(name: "Person", bundle: nil)
            let personController = storyboard.instantiateViewController(withIdentifier: "PersonTableViewController") as! PersonTableViewController
            personController.navigator = self
            personController.personId = id
            return personController
            
        case .movieColletion(let id):
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            let movieCollection = MovieCollectionViewController(collectionViewLayout: layout, collectionId: id, navigator: self)
            return movieCollection
            
        case .list(let listRequest):
            let listController = ListTableViewController(requestType: listRequest, title: listRequest.rawValue.title, navigator: self)
            return listController
        }
    }
    
    func darkThemeEnabled() {
        self.navigation.navigationBar.barStyle = .blackTranslucent
        self.navigation.navigationBar.tintColor = .lightBlueTint
    }
    
    func darkThemeDisabled() {
        self.navigation.navigationBar.barStyle = .default
        self.navigation.navigationBar.isTranslucent = true
        self.navigation.navigationBar.tintColor = .defaultBlueTint
    }
    
}
