struct Cinema {
    var address: String
    var name: String
    var isOpened: Bool?
    var lat: Double
    var lng: Double
    
    init?(from json: Dictionary<String, Any>) {
        
//        guard let address = json["formatted_address"] as? String,
//            let geometry = json["geometry"] as? [String: Any],
//            let location = geometry["location"] as? [String: Any],
//            let latitude = location["lat"] as? Double,
//            let longitude = location["lng"] as? Double,
//            let name = json["name"] as? String else { return nil }
        
        guard let address = json["vicinity"] as? String,
            let geometry = json["geometry"] as? [String: Any],
            let location = geometry["location"] as? [String: Any],
            let latitude = location["lat"] as? Double,
            let longitude = location["lng"] as? Double,
            let name = json["name"] as? String else { return nil }
        
        self.address = address
        self.name = name
        self.lat = latitude
        self.lng = longitude
        
        if let openingHours = json["opening_hours"] as? [String: Any],
            let openedNow = openingHours["open_now"] as? Bool {
            self.isOpened = openedNow
        }
    }
}
