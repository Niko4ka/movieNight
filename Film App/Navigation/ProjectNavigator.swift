import UIKit

protocol Navigator: class {
    
    associatedtype Destination
    
    init(navigationController: UINavigationController, isDarkMode: Bool)
    func navigate(to destination: Destination)
}

class ProjectNavigator: Navigator {
    
    enum Destination {
        case movie(id: Int, type: MediaType)
        case person(id: Int)
        case movieColletion(id: Int)
        case list
    }
    
    private weak var navigation: UINavigationController!
    
    required init(navigationController: UINavigationController, isDarkMode: Bool) {
        self.navigation = navigationController
        if isDarkMode {
            self.navigation.navigationBar.barStyle = .blackTranslucent
        } else {
            self.navigation.navigationBar.isTranslucent = true
        }
    }
    
    func navigate(to destination: Destination) {
        guard let viewController = makeViewController(for: destination) else { return }
        navigation?.pushViewController(viewController, animated: true)
        
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
            
        case .list:
            let listController = ListTableViewController(requestType: .popularMovies, title: "Popular movies")
            return listController
        }
    }
    
}
