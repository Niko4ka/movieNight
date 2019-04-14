import UIKit

extension UIViewController {
    
    func showError(withMessage message: String? = nil, completion: (()->())? = nil) {
        
        let commonMessage = "Looks like something went wrong :( \n Please, try again later"
        
        let alertMessage = message ?? commonMessage
        let alert = UIAlertController(title: "Ooops...", message: alertMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
            if completion != nil {
                completion!()
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}
