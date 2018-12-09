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
        
    }
    
    @IBAction func signInVKButtonPressed(_ sender: UIButton) {
        VKHandler.shared.vkLogin { (authorized) in
            if authorized {
                print("Пользователь авторизован")
            } else {
                print("Пользователь не авторизован")
            }
        }
    }
    
    @IBAction func VKLogout(_ sender: UIButton) {
        VKHandler.shared.vkLogout()
    }

    
    
}


