import Foundation

/// Data structure, that contains common information about the movie, in which the person took part
struct PersonMovie {
    
    var id: Int
    var mediaType: MediaType
    var title: String
    var year: String?
    var character: String
    var posterUrl: URL?
    
    init?(ofType type: MediaType, from json: [String: Any]) {
        
        self.mediaType = type
        
        guard let id = json["id"] as? Int,
            let character = json["character"] as? String else { return nil }
        
        self.id = id
        self.character = character
        
        if let title = json["title"] as? String {
            self.title = title
        } else {
            guard let name = json["name"] as? String else { return nil }
            self.title = name
        }
        
        if type == .movie {
            if let releaseDate = json["release_date"] as? String {
                self.year = releaseDate.getYear()
            }
        } else {
            if let releaseDate = json["first_air_date"] as? String {
                self.year = releaseDate.getYear()
            }
        }
        
        if let posterPath = json["poster_path"] as? String {
            self.posterUrl = URL(string: "https://image.tmdb.org/t/p/w500/\(posterPath)")
        }
  
    }
    
}

