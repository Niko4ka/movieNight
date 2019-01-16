import UIKit
import VKSdkFramework

/**
Helper for VK authorization
 */

class VKHandler: NSObject {
    
    static let shared = VKHandler()
    
    static let VK_APP_ID = "6749149"
    let permissions = ["email"] as [AnyObject]
    
    var userEmail: String!
    var userID: String!
    var token: String!
    
    func vkLogin(completion: @escaping (Bool) -> ()) {
        VKSdk.wakeUpSession(self.permissions) { (state, error) in
            if state == .authorized && error == nil && VKSdk.accessToken() != nil {
                print("Vk authorized")
                completion(true)
            } else if state == .initialized {
                print("vk initialized")
                VKSdk.authorize(self.permissions)
            } else {
                completion(false)
            }
        }
    }
    
    func vkLogout() {
        print("Пользователь разлогинен")
        VKSdk.forceLogout()
    }
    
}

extension VKHandler: VKSdkDelegate, VKSdkUIDelegate {

    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if ((result.token) != nil) {
            print("Пользователь успешно авторизован")
            
            if let email = result.token.email, let token = result.token.accessToken, let id = result.token.userId {
                self.userEmail = email
                self.token = token
                self.userID = id
 
                KeychainService.shared.saveToken(account: KeychainService.Accounts.vkontakte.rawValue, token: token)

                let authController = AuthViewController()
                authController.authorizeUser()
            }
                        
        } else if ((result.error) != nil) {
            print("Пользователь отменил авторизацию или произошла ошибка")
            // Пользователь отменил авторизацию или произошла ошибка
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        print("Authorization failed")
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        print("vksdkshouldPresent")
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            rootController.present(controller, animated: true)
        }
        
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("vkSdkNeedCaptchaEnter")
    }
    
    
}