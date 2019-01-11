struct PersonInfo {
    var name: String
    var gender: Int
    var department: String?
    var profilePath: String?
    var birthday: String?
    var deathday: String?
}

extension Client {
    
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
