struct PersonInfo {
    var name: String
    var gender: Int
    var department: String?
    var profilePath: String?
    var birthday: String?
    var deathday: String?
}

extension Client {
    
    /// Loads main information about particular person
    ///
    /// - Parameters:
    ///   - id: person id
    ///   - completion: completion handler, which contains PersonInfo if success or nil if failed
    func loadPersonInfo(id: Int, completion: @escaping (PersonInfo?)->Void) {

        request(path: "/person/\(id)").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any] else { return }
            
            guard let name = json["name"] as? String,
                let gender = json["gender"] as? Int else  {
                completion(nil)
                return
            }
            
            let department = json["known_for_department"] as? String
            let profilePath = json["profile_path"] as? String
            let birthday = json["birthday"] as? String
            let deathday: String? = json["deathday"] as? String
            
            let info = PersonInfo(name: name, gender: gender, department: department, profilePath: profilePath, birthday: birthday, deathday: deathday)
            
            completion(info)
        }
        
    }
    
    /// Loads movies, in which particular person took part
    ///
    /// - Parameters:
    ///   - id: person id
    ///   - completion: completion handler, which contains an array of PersonMovie structures if success or an empty array if failed
    func loadPersonMovies(personId id: Int, completion: @escaping ([PersonMovie])->Void) {
        
        request(path: "/person/\(id)/movie_credits").responseJSON { (response) in
            guard let json = response.result.value as? [String: Any],
                let cast = json["cast"] as? [Dictionary<String, Any>] else {
                completion([])
                return
            }

            let movies = cast.compactMap { PersonMovie(ofType: .movie, from: $0) }
            completion(movies)
        }
    }
    
    /// Loads TV Shows, in which particular person took part
    ///
    /// - Parameters:
    ///   - id: person id
    ///   - completion: completion handler, which contains an array of PersonMovie structures if success or an empty array if failed
    func loadPersonTvShows(personId id: Int, completion: @escaping ([PersonMovie])->Void) {
        
        request(path: "/person/\(id)/tv_credits").responseJSON { (response) in
            
            guard let json = response.result.value as? [String: Any],
                let cast = json["cast"] as? [Dictionary<String, Any>] else {
                    completion([])
                    return
            }
            
            let tvShows = cast.compactMap { PersonMovie(ofType: .tvShow, from: $0) }
            completion(tvShows)
        }
        
    }

}
