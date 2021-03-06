import Foundation
import Alamofire

final class ConfigurationService {
    
    static let shared = ConfigurationService()
    
    private init() {}
    
    private let themoviedbKey = "81c0943d1596e1cc2b1c8de9e9ba8945"
    public var movieGenres: [Int: String]!
    public var tvGenres: [Int: String]!
    public var countries: [String: String]!
    
    /// Load movie genres
    ///
    /// - Parameter completion: closure after loading finished, contains [Genre id : Genre name]
    func getMovieGenres(completion: @escaping ([Int: String]) -> ()) {
        
        AF.request("https://api.themoviedb.org/3/genre/movie/list?api_key=\(themoviedbKey)&language=en-US").responseJSON(completionHandler: { (response) in
            
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
    
    /// Load TV Show genres
    ///
    /// - Parameter completion: closure after loading finished, contains [Genre id : Genre name]
    func getTvGenres(completion: @escaping ([Int: String]) -> ()) {
        
        AF.request("https://api.themoviedb.org/3/genre/tv/list?api_key=\(themoviedbKey)").responseJSON { (response) in
            
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
        }
        
    }
    
    /// Load production countries
    ///
    /// - Parameter completion: closure after loading finished, contains [Country id : Country name]
    func getCountries(completion: @escaping ([String: String]) -> ()) {
        
        AF.request("https://api.themoviedb.org/3/configuration/countries?api_key=\(themoviedbKey)").responseJSON { (response) in
            
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
