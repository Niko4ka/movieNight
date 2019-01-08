import Foundation

struct MovieCast {
    
    var actors: [CastPerson] = []
    var director: String?
    var writer: String?
    var producers: [String] = []
    
    
    init?(ofType type: MediaType,from json: [String: Any]) {
        
        guard let cast = json["cast"] as? [Dictionary<String, Any>],
            let crew = json["crew"] as? [Dictionary<String, Any>] else {
                return nil
        }
        
        var castQuantity: Int!
        if cast.count >= 10 {
            castQuantity = 10
        } else {
            castQuantity = cast.count
        }
        
        for i in 0..<castQuantity {
            let actor = cast[i]
            if let name = actor["name"] as? String,
                let personId = actor["id"] as? Int {
                let castPerson = CastPerson(name: name, id: personId)
                self.actors.append(castPerson)
            }
        }
        
        for member in crew {
            
            if let job = member["job"] as? String,
                let name = member["name"] as? String {
                
                if type == MediaType.movie {
                    
                    switch job {
                    case "Director":
                        self.director = name
                    case "Writer":
                        self.writer = name
                    case "Producer":
                        self.producers.append(name)
                    default:
                        break
                    }
                    
                } else {
                    
                    switch job {
                    case "Director":
                        self.director = name
                    case "Novel":
                        self.writer = name
                    case "Executive Producer":
                        self.producers.append(name)
                    default:
                        break
                    }
                }
            }
        }
    }
}

struct CastPerson {
    var name: String
    var id: Int
}
