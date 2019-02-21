import UIKit
import UserNotifications
//import VKSdkFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
/*  Uncomment if using authorization
        
         VK SDK
        let vkSDK = VKSdk.initialize(withAppId: VKHandler.VK_APP_ID)
        vkSDK?.register(VKHandler.shared)
        vkSDK?.uiDelegate = VKHandler.shared
 
         Root Controller
 
        if KeychainService.shared.readToken(account: KeychainService.Accounts.vkontakte.rawValue) != nil {

            window = UIWindow()
            window?.rootViewController = TabBarController()
            window?.makeKeyAndVisible()

        } else {
            let storyboard = UIStoryboard(name: "Authorization", bundle: Bundle.main)

            guard let authController = storyboard.instantiateViewController(withIdentifier: "AuthController") as? AuthViewController else {
                return false
            }

            window = UIWindow()
            window?.rootViewController = authController
            window?.makeKeyAndVisible()
        }
         
*/
        
        window = UIWindow()
        window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        
        ConfigurationService.shared.getMovieGenres { (genres) in
            ConfigurationService.shared.movieGenres = genres
        }
        
        ConfigurationService.shared.getTvGenres { (genres) in
            ConfigurationService.shared.tvGenres = genres
        }
        
        ConfigurationService.shared.getCountries { (countries) in
            ConfigurationService.shared.countries = countries
        }
        
        // For sending notifications
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        }
        
        let currentThemeIsDark = UserDefaults.standard.bool(forKey: "isDarkTheme")
        if currentThemeIsDark {
            NotificationCenter.default.post(name: .darkThemeEnabled, object: nil)
            print("Post dark theme")
        } else {
            NotificationCenter.default.post(name: .darkThemeDisabled, object: nil)
            print("Post light theme")
        }
        

        return true
    }
    
/*  Uncomment if using authorization
     
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        VKSdk.processOpen(url, fromApplication: sourceApplication)
        return true
    }

*/

    func applicationWillResignActive(_ application: UIApplication) {
        // TODO: Останавливать таймер в MoviesViewController
    }


}

