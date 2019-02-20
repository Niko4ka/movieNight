import Foundation

extension Notification.Name {
    static var darkThemeEnabled: Notification.Name {
        return .init("darkThemeEnabled")
    }
    
    static var darkThemeDisabled: Notification.Name {
        return .init("darkThemeDisabled")
    }
}
