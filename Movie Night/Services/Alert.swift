import UIKit

class Alert {
    
    static let shared = Alert()
    private init() {}
    
    let commonMessage = "Looks like something went wrong :( \n Please, try again later"
    
    func show(on controller: UIViewController, withMessage message: String? = nil, completion: (()->())? = nil) {
        let alertMessage = message != nil ? message : commonMessage
        let alert = UIAlertController(title: "Ooops...", message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
            if completion != nil {
                completion!()
            }
        }
        alert.addAction(action)
        controller.present(alert, animated: true, completion: nil)
    }
    
}
