//
//  RatingControl.swift
//  Film App
//
//  Created by Вероника Данилова on 18/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

class RatingControl: UIStackView {
    
    var rating: Int = 0
    var numberOfVotes: Int = 0
    let emptyStar = UIImage(named: "emptyStar")
    let fullStar = UIImage(named: "fullStar")
    let halfStar = UIImage(named: "halfStar")
    
    public func setRating(_ rate: Double, from numberOfVotes: Int) {
        let roundedRate = rate.rounded()
        self.rating = Int(roundedRate)
        print("Rating - \(rating)")
        self.numberOfVotes = numberOfVotes
        
        for i in stride(from: 2, to: 11, by: 2) {
            if i <= rating {
                createStar(withImage: fullStar!)
            } else if i > rating && i - 1 == rating {
                createStar(withImage: halfStar!)
            } else {
                createStar(withImage: emptyStar!)
            }
        }
        
        let label = UILabel()
        label.text = "(\(numberOfVotes))"
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.textColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
        label.sizeToFit()
        addArrangedSubview(label)
        
        let viewWidth = (self.frame.height * 5) + 10.0 + label.frame.width
        self.widthAnchor.constraint(equalToConstant: viewWidth).isActive = true
    }
    
    private func createStar(withImage image: UIImage) {
        let star = UIImageView(image: image)
        star.translatesAutoresizingMaskIntoConstraints = false
        star.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
        star.widthAnchor.constraint(equalToConstant: self.frame.height).isActive = true
        addArrangedSubview(star)
    }
    
    
    
    
}
