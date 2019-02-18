//
//  WishlistViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 18/02/2019.
//  Copyright © 2019 Veronika Danilova. All rights reserved.
//

import UIKit

class WishlistViewController: UIViewController {
    
    var navigator: ProjectNavigator?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Mode", style: .plain, target: self, action: #selector(selectViewMode))

        showAsTable()
        
    }
    
    @objc func selectViewMode() {
        
        let sheet = UIAlertController(title: "Select prefered view mode", message: nil, preferredStyle: .actionSheet)
        let tableMode = UIAlertAction(title: "List", style: .default) { _ in
            self.showAsTable()
            print("List")
        }
        let collectionMode = UIAlertAction(title: "Collection", style: .default) { _ in
            self.showAsCollection()
            print("Collection")
        }
        sheet.addAction(tableMode)
        sheet.addAction(collectionMode)
        present(sheet, animated: true, completion: nil)
    }

    private func showAsTable() {
        let wishlistTable = WishlistTableViewController()
        wishlistTable.navigator = navigator
        addChild(wishlistTable)
        view.addSubview(wishlistTable.view)
        wishlistTable.didMove(toParent: self)
    }
    
    private func showAsCollection() {
        
    }

}
