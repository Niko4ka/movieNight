//
//  GenresService.swift
//  Film App
//
//  Created by Вероника Данилова on 14/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import Foundation
import Alamofire

class Genres {
    
    static let shared = Genres()
    
    public var moviesGenres: [Int: String]!
    public var tvGenres: [Int: String]!
    
    public func getMoviesGenres(completion: @escaping ([Int: String]) -> ()) {
        
        AF.request("https://api.themoviedb.org/3/genre/movie/list?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US").responseJSON(completionHandler: { (response) in
            
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
        })

    }
    
    public func getTvGenres(completion: @escaping ([Int: String]) -> ()) {
        
        AF.request("https://api.themoviedb.org/3/genre/tv/list?api_key=81c0943d1596e1cc2b1c8de9e9ba8945&language=en-US").responseJSON(completionHandler: { (response) in
            
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
        })
        
    }
    
}
