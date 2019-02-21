import Foundation

extension Notification.Name {
    static var darkThemeEnabled: Notification.Name {
        return .init("darkThemeEnabled")
    }
    
    static var darkThemeDisabled: Notification.Name {
        return .init("darkThemeDisabled")
    }
    
    static var listWishlistViewSelected: Notification.Name {
        return .init("listWishlistView")
    }
    
    static var collectionWishlistViewSelected: Notification.Name {
        return .init("collectionWishlistView")
    }
    
}
