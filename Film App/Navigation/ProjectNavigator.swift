import UIKit

class ProjectNavigator: Navigator {
    
    enum Destination {
        case movie(id: Int, type: MediaType)
    }
    
    private weak var navigation: UINavigationController?
    
    required init(navigationController: UINavigationController) {
        self.navigation = navigationController
    }
    
    func navigate(to destination: Destination) {
        guard let viewController = makeViewController(for: destination) else { return }
        navigation?.pushViewController(viewController, animated: true)
        
    }
    
    private func makeViewController(for destination: Destination) -> UIViewController? {
        switch destination {
        case .movie(let id, let type):
            let storyboard = UIStoryboard(name: "Movie", bundle: nil)
            guard let controller = storyboard.instantiateViewController(withIdentifier: "MovieTableViewController") as? MovieTableViewController else { return nil }
            controller.movieId = id
            controller.mediaType = type
            return controller
        }
    }
    
    
}
