import UIKit

class Alert {
    
    static let shared = Alert()
    private init() {}
    
    func show(on controller: UIViewController, withMessage message: String) {
        let alert = UIAlertController(title: "Ooops...", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
    
}
