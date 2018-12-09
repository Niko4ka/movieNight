//
//  authButton.swift
//  Film App
//
//  Created by Вероника Данилова on 27.10.2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class authButton: UIButton {
    
    var image: UIImage?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 8.0
        
        switch self.restorationIdentifier {
        case "googleAuth":
            image = UIImage(named: "google_icon")
        case "vkAuth":
            image = UIImage(named: "vk_icon")
        case "fbAuth":
            image = UIImage(named: "fb_icon")
        default:
            return
        }
        
        self.setImage(image, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        self.moveImageLeftTextCenter()

    }
    
    func moveImageLeftTextCenter(){
        let imagePadding: CGFloat = 20.0
        guard let imageViewWidth = self.imageView?.frame.width else{return}
        guard let titleLabelWidth = self.titleLabel?.intrinsicContentSize.width else{return}
        self.contentHorizontalAlignment = .left
        imageEdgeInsets = UIEdgeInsets(top: 16, left: imagePadding - imageViewWidth / 2, bottom: 16.0, right: 0.0)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: (bounds.width - titleLabelWidth) / 2 - imageViewWidth, bottom: 0.0, right: 0.0)
    }
    
    

}
