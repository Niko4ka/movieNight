import UIKit

class AuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: - Сейчас есть только VK, потом нужно будет сделать проверку на наличие других токенов
    
    }

    @IBAction func signInVKButtonPressed(_ sender: UIButton) {
        VKHandler.shared.vkLogin { (authorized) in
            if authorized {
                print("Пользователь авторизован")
                self.authorizeUser()
            } else {
                print("Пользователь не авторизован")
            }
        }
    }
    
    @IBAction func VKLogout(_ sender: UIButton) {
        VKHandler.shared.vkLogout()
    }

    public func authorizeUser() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = tabBarController
    }
    
}


