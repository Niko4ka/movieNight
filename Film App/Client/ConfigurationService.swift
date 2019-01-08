import Foundation
import Alamofire

class ConfigurationService {
    
    static let shared = ConfigurationService()
    static let themoviedbKey = "81c0943d1596e1cc2b1c8de9e9ba8945"
    static let googleKey = "AIzaSyAluG5wfH3vDhket7F2b2pFAzdgKH6F4mk"
    
    static let client = Client()
    
    public var moviesGenres: [Int: String]!
    public var tvGenres: [Int: String]!
    public var countries: [String: String]!
    
    public func getMoviesGenres(completion: @escaping ([Int: String]) -> ()) {
        
        AF.request("https://api.themoviedb.org/3/genre/movie/list?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US").responseJSON(completionHandler: { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let dictionary = json["genres"] as? [Dictionary<String, Any>] else {
                    return
            }
            
            var genres = [Int: String]()
            
            for genre in dictionary {
                if let id = genre["id"] as? Int,
                    let name = genre["name"] as? String {
                    genres[id] = name
                }
            }
            completion(genres)
        })

    }
    
    public func getTvGenres(completion: @escaping ([Int: String]) -> ()) {
        
        AF.request("https://api.themoviedb.org/3/genre/tv/list?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let dictionary = json["genres"] as? [Dictionary<String, Any>] else {
                    print(" --- genres ---- error")
                    return
            }
            
            var genres = [Int: String]()
            
            for genre in dictionary {
                if let id = genre["id"] as? Int,
                    let name = genre["name"] as? String {
                    genres[id] = name
                }
            }
            completion(genres)
        }
        
    }
    
    public func getCountries(completion: @escaping ([String: String]) -> ()) {
        
        AF.request("https://api.themoviedb.org/3/configuration/countries?api_key=81c0943d1596e1cc2b1c8de9e9ba8945").responseJSON { (response) in
            
            guard let json = response.result.value as? [Dictionary<String, String>] else { return }
            
            var countries = [String: String]()
            
            for country in json {
                if let index = country["iso_3166_1"],
                    let name = country["english_name"] {
                    countries[index] = name
                }
            }
            
            completion(countries)
        }
    }
    
}
