import UserNotifications

class NotificationService {
    
    static let shared = NotificationService()
    private init() {}
    
    func planReminderNotification() {
        
        removeNotifications(withIdentifiers: ["Reminder notification"])
        
        let timeIntervalInSeconds: Double = 60 * 60 * 24 // 24 hours in seconds
        let date = Date(timeIntervalSinceNow: timeIntervalInSeconds)
        
        let content = UNMutableNotificationContent()
        content.title = "There are movies in your wishlist!"
        content.body = "Have you seen all the movies, you've planned?"
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "Reminder notification", content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
        
    }
    
    func removeReminderNotification() {
        removeNotifications(withIdentifiers: ["Reminder notification"])
    }
    
    private func removeNotifications(withIdentifiers identifiers: [String]) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
