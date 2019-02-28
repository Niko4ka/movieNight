import Alamofire

extension Client {
    
    func searchCinemas(lat: Double, lng: Double, completion: @escaping ([Cinema]?)->Void) {
        
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        let params: [String:Any] = [
            "rankby" : "distance",
            "location" : "\(lat), \(lng)",
            "type" : "movie_theater",
            "key" : googleKey
        ]
        
        AF.request(url, parameters: params).responseJSON { (response) in
            guard let json = response.result.value as? [String: Any],
                let results = json["results"] as? [Dictionary<String, Any>] else {
                    completion(nil)
                    return
            }
            
            let cinemas = results.compactMap { Cinema(from: $0) }
            completion(cinemas)
        }
        
    }
    
//    func getCinemaDetails(byId id: String, completion: @escaping ([Cinema]?)->Void) {
//        let url = "https://maps.googleapis.com/maps/api/place/details/json"
//        let params: [String:Any] = [
//            "placeid" : id,
//            "key" : googleKey
//        ]
//
//        AF.request(url, parameters: params).responseJSON { (response) in
//
//        }
//    }
    
}
