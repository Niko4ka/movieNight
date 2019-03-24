import Foundation

protocol ColorThemeObserver: class, NSObjectProtocol {

    func darkThemeEnabled()
    func darkThemeDisabled()
}

protocol ColorThemeCellObserver: ColorThemeObserver {
    var isDarkTheme: Bool { get set }
}

extension ColorThemeCellObserver where Self: WishlistMainViewProtocol {
    func darkThemeEnabled() {}
    func darkThemeDisabled() {}
}

extension ColorThemeObserver {
    
    func setupColorThemeObserver() {
        addColorThemeObservers()
        checkCurrentColorTheme()
    }
    
    private func addColorThemeObservers() {
        
        NotificationCenter.default.addObserver(forName: .darkThemeEnabled, object: nil, queue: nil) { [weak self] (notification) in
            self?.darkThemeEnabled()
        }
        
        NotificationCenter.default.addObserver(forName: .darkThemeDisabled, object: nil, queue: nil) { [weak self] (notification) in
            self?.darkThemeDisabled()
        }
    }
    
    private func checkCurrentColorTheme() {
        
        let currentThemeIsDark = UserDefaults.standard.bool(forKey: "isDarkTheme")
        if currentThemeIsDark {
            darkThemeEnabled()
        } else {
            darkThemeDisabled()
        }
    }
    
}
