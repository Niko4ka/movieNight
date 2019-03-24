import UIKit

extension ColorThemeObserver where Self: UIViewController {
    
    func addColorThemeObservers() {

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: .darkThemeEnabled, object: nil, queue: nil) { [weak self] (notification) in
            guard self != nil else { return }
            self?.darkThemeEnabled()
        }
        notificationCenter.addObserver(forName: .darkThemeDisabled, object: nil, queue: nil) { [weak self] (notification) in
            guard self != nil else { return }
            self?.darkThemeDisabled()
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(ColorThemeObserver.darkThemeEnabled), name: .darkThemeEnabled, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(ColorThemeObserver.darkThemeDisabled), name: .darkThemeDisabled, object: nil)
    }
    
    func checkCurrentColorTheme() {
        
        let currentThemeIsDark = UserDefaults.standard.bool(forKey: "isDarkTheme")
        if currentThemeIsDark {
            self.darkThemeEnabled()
        } else {
            self.darkThemeDisabled()
        }
    }
    
}
