import UIKit

extension UIViewController {
    
    func addColorThemeObservers() {
        
        guard self is ColorThemeObserver else  { return }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ColorThemeObserver.darkThemeEnabled), name: .darkThemeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ColorThemeObserver.darkThemeDisabled), name: .darkThemeDisabled, object: nil)
    }
    
    func checkCurrentColorTheme() {
        
        guard let controller = self as? ColorThemeObserver else  { return }
        
        let currentThemeIsDark = UserDefaults.standard.bool(forKey: "isDarkTheme")
        if currentThemeIsDark {
            controller.darkThemeEnabled()
        } else {
            controller.darkThemeDisabled()
        }
    }
    
}
