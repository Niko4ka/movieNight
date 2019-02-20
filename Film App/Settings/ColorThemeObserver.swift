import Foundation

@objc protocol ColorThemeObserver: class {
    
    @objc func darkThemeEnabled()
    @objc func darkThemeDisabled()
    
}
