import UIKit

class UISearchBarNoCancel: UISearchBar {
    
    override func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool) {
        super.setShowsCancelButton(false, animated: animated)
    }
    
}
