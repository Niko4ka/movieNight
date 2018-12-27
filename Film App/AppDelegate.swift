//
//  AppDelegate.swift
//  Film App
//
//  Created by Вероника Данилова on 26.10.2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit
import VKSdkFramework
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        let session = AVAudioSession.sharedInstance()
//        do {
//            try session.setCategory(.ambient, mode: .default, options: [])
//            try session.setActive(true, options: [])
//        } catch {
//            print("Session error")
//        }
//
        

        // VK SDK
        let vkSDK = VKSdk.initialize(withAppId: VKHandler.VK_APP_ID)
        vkSDK?.register(VKHandler.shared)
        vkSDK?.uiDelegate = VKHandler.shared
        
        // Root Controller
        
        if let token = KeychainService.shared.readToken(account: KeychainService.Accounts.vkontakte.rawValue) {

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else {
                return false
            }
            
            window = UIWindow()
            window?.rootViewController = tabBarController
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
        
        ConfigurationService.shared.getMoviesGenres { (genres) in
            ConfigurationService.shared.moviesGenres = genres
        }
        
        ConfigurationService.shared.getTvGenres { (genres) in
            ConfigurationService.shared.tvGenres = genres
        }
        
        ConfigurationService.shared.getCountries { (countries) in
            ConfigurationService.shared.countries = countries
        }

        return true
    }
    

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        VKSdk.processOpen(url, fromApplication: sourceApplication)
        return true
    }

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

