import Foundation

@objc protocol ColorThemeObserver: class {

    @objc func darkThemeEnabled()
    @objc func darkThemeDisabled()
    
}

protocol ColorThemeCellObserver: ColorThemeObserver {
    var isDarkTheme: Bool { get set }
}

protocol WishlistColorThemeObserver {
    var isDarkTheme: Bool { get set }
}
