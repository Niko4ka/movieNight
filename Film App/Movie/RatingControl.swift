import UIKit

/// Represents star-rating view
class RatingControl: UIStackView {
    
    var rating: Int = 0
    var numberOfVotes: Int = 0
    let emptyStar = UIImage(named: "emptyStar")
    let fullStar = UIImage(named: "fullStar")
    let halfStar = UIImage(named: "halfStar")
    
    public func setRating(_ rate: Double, from numberOfVotes: Int) {
        let roundedRate = rate.rounded()
        self.rating = Int(roundedRate)
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
        label.text = " (\(numberOfVotes))"
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.textColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
        label.sizeToFit()
        addArrangedSubview(label)
        
        let viewWidth = (self.frame.height * 5) + 10.0 + label.frame.width
        
        if let index = constraints.index(where: { $0.identifier == "ratingControlWidth" }), let widthConstraint = [constraints[index]].first {
            widthConstraint.constant = viewWidth
        }

    }
    
    /// Clears stackView (for using in reusable cells)
    public func removeArrangedViews() {
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    private func createStar(withImage image: UIImage) {
        let star = UIImageView(image: image)
        star.translatesAutoresizingMaskIntoConstraints = false
        star.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
        star.widthAnchor.constraint(equalToConstant: self.frame.height).isActive = true
        addArrangedSubview(star)
    }
    
}
