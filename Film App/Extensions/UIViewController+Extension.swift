import UIKit

extension UIViewController {
    
    func addColorThemeObservers() {
        
        guard self is ColorThemeObserver else  { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ColorThemeObserver.darkThemeEnabled), name: .darkThemeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ColorThemeObserver.darkThemeDisabled), name: .darkThemeDisabled, object: nil)
    }
    
}
