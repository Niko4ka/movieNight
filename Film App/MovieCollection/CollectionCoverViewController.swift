//
//  CollectionCoverViewController.swift
//  Film App
//
//  Created by Вероника Данилова on 16/01/2019.
//  Copyright © 2019 Veronika Danilova. All rights reserved.
//

import UIKit
import Kingfisher

class CollectionCoverViewController: UIViewController {
    
    private var coverUrl: URL!
    lazy private var coverImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        imageView.backgroundColor = UIColor.black
        imageView.contentMode = .scaleAspectFit
        self.view.addSubview(imageView)
        return imageView
    }()
    
    init(coverUrl: URL) {
        self.coverUrl = coverUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        coverImageView.kf.setImage(with: coverUrl)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1, delay: 1, options: .curveEaseOut, animations: {
//            self.coverImageView.frame.origin = CGPoint(x: -UIScreen.main.bounds.maxX, y: UIScreen.main.bounds.maxY)
            self.coverImageView.frame.origin = CGPoint(x: -(UIScreen.main.bounds.maxX * 1.5), y: self.coverImageView.frame.origin.y)
            self.coverImageView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            
            self.coverImageView.layer.opacity = 0.4
        }, completion: { (true) in
            self.dismiss(animated: false, completion: nil)
        })
    }
    

}
