import UIKit

protocol Navigator: class {
    
    associatedtype Destination
    
    init(navigationController: UINavigationController)
    func navigate(to destination: Destination)
}
