import Foundation

struct MovieDetails {
    var id: Int
    var posterUrl: URL?
    var backdropUrl: URL?
    var title: String
    var releaseDate: String = "-"
    var description: String = ""
    var countries: String
    var status: String
    var runtime: Int?
    var genres: String
    var tvShowSeasons: Int?
    var rating: Double
    var voteCount: Int
    
    init?(ofType type: MediaType, from json: [String: Any]) {
        
        guard let status = json["status"] as? String,
            let id = json["id"] as? Int,
            let genres = json["genres"] as? [Dictionary<String, Any>],
            let rating = json["vote_average"] as? Double,
            let voteCount = json["vote_count"] as? Int
            else { return nil }

        self.status = status
        self.id = id
        self.rating = rating
        self.voteCount = voteCount
        
        if type == .movie {
            guard let title = json["title"] as? String,
                let releaseDate = json["release_date"] as? String,
                let countries = json["production_countries"] as? [Dictionary<String, String>]
                else { return nil }
            
            self.title = title
            self.releaseDate = releaseDate.formattedDate()
            
            var countriesString = ""
            for country in countries {
                if let countryName = country["name"] {
                    if countriesString.isEmpty {
                        countriesString.append(countryName)
                    } else {
                        countriesString.append(", " + countryName)
                    }
                }
            }
            self.countries = countriesString
            
            
        } else {
            guard let title = json["name"] as? String,
                let countries = json["origin_country"] as? [String]
                else { return nil }
            
            self.title = title
            
            
            if let releaseDate = json["first_air_date"] as? String {
                self.releaseDate = releaseDate.formattedDate()
            }
            
            var countriesString = ""
            for countryIndex in countries {
                
                if let countryName = ConfigurationService.shared.countries[countryIndex] {
                    if countriesString.isEmpty {
                        countriesString.append(countryName)
                    } else {
                        countriesString.append(", " + countryName)
                    }
                }
            }
            self.countries = countriesString
        }
        
        if let imageString = json["poster_path"] as? String {
            self.posterUrl = URL(string: "https://image.tmdb.org/t/p/w500/\(imageString)")
        }
        
        if let backdropString = json["backdrop_path"] as? String {
            self.backdropUrl = URL(string: "https://image.tmdb.org/t/p/w780/\(backdropString)")
        }
        
        if let description = json["overview"] as? String {
            self.description = description
        }
        
        if let runtime = json["runtime"] as? Int {
            self.runtime = runtime
        }
        
        var genresString = ""
        for genre in genres {
            if let name = genre["name"] as? String {
                if genresString.isEmpty {
                    genresString.append(name)
                } else {
                    genresString.append(", " + name)
                }
            }
        }
        self.genres = genresString
        
        if let seasons = json["number_of_seasons"] as? Int {
            self.tvShowSeasons = seasons
        }

    }
    
}
