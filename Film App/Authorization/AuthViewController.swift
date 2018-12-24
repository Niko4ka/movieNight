//
//  ViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 26.10.2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: - Сейчас есть только VK, потом нужно будет сделать проверку на наличие других токенов
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if let token = KeychainService.shared.readToken(account: KeychainService.Accounts.vkontakte.rawValue) {
//            print("Есть токен - \(token)")
//            authorizeUser()
//        }
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
        
        print("Authorize user")
        
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = tabBarController
        print("Root controller - \(UIApplication.shared.keyWindow?.rootViewController)")
    }
    
}


