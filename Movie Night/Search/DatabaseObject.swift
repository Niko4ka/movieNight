import Foundation

/// Data structure, that contains common information about the mediatype item
struct DatabaseObject {

    var mediaType: MediaType
    var image: String?
    var genres: String = ""
    var title: String
    var id: Int

    
    init?(fromJson json: [String: Any]) {
        
        guard let mediaType = json["media_type"] as? String,
            let id = json["id"] as? Int else {
                return nil
        }
        
        if let posterImage = json["poster_path"] as? String {
            self.image = posterImage
        } else if let personImage = json["profile_path"] as? String {
            self.image = personImage
        }
        
        if let title = json["title"] as? String {
            self.title = title
        } else {
            guard let name = json["name"] as? String else { return nil }
            self.title = name
        }
        
        if let genreIds = json["genre_ids"] as? Array<Int> {

            for i in 0..<genreIds.count {

                switch mediaType {
                case "movie":
                    
                    if let movieGenres = ConfigurationService.shared.movieGenres,
                        let genre = movieGenres[genreIds[i]] {
                        if self.genres.isEmpty {
                            self.genres.append(genre)
                        } else {
                            self.genres.append(", " + genre)
                        }
                    }
                case "tv":
                    
                    if let tvGenres = ConfigurationService.shared.tvGenres,
                        let genre = tvGenres[genreIds[i]] {
                        if self.genres.isEmpty {
                            self.genres.append(genre)
                        } else {
                            self.genres.append(", " + genre)
                        }
                    }
                    
                default:
                    break
                }
            }
        }
        
        switch mediaType {
        case "movie":
            self.mediaType = MediaType.movie
        case "tv":
            self.mediaType = MediaType.tvShow
        case "person":
            self.mediaType = MediaType.person
        default:
            return nil
        }
        
        self.id = id
    }
    
    init?(ofType type: MediaType, fromJson json: [String: Any]) {
        
        guard let id = json["id"] as? Int else {
                return nil
        }
        
        self.id = id
        self.mediaType = type
        
        if let posterImage = json["poster_path"] as? String {
            self.image = posterImage
        }
        
        if let title = json["title"] as? String {
            self.title = title
        } else {
            guard let name = json["name"] as? String else { return nil }
            self.title = name
        }
        
        if let genreIds = json["genre_ids"] as? Array<Int> {
            
            for i in 0..<genreIds.count {
                
                switch type {
                case .movie:
                    
                    if let movieGenres = ConfigurationService.shared.movieGenres,
                        let genre = movieGenres[genreIds[i]] {
                        if self.genres.isEmpty {
                            self.genres.append(genre)
                        } else {
                            self.genres.append(", " + genre)
                        }
                    }
                case .tvShow:
                    
                    if let tvGenres = ConfigurationService.shared.tvGenres,
                        let genre = tvGenres[genreIds[i]] {
                        if self.genres.isEmpty {
                            self.genres.append(genre)
                        } else {
                            self.genres.append(", " + genre)
                        }
                    }
                default:
                    break
                }
            }
        }

    }
    
}
