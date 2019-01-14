import UIKit
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

        return true
    }
    
/*  Uncomment if using authorization
     
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        VKSdk.processOpen(url, fromApplication: sourceApplication)
        return true
    }

*/

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

