import UIKit

extension UIView {
    
    func lookupSubview<T: UIView>() -> T? {
        if let value = self as? T {
            return value
        }
        
        for subview in subviews {
            if let x:T = subview.lookupSubview() {
                return x
            }
        }
        
        return nil
    }
    
}
