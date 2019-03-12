class GenreSection {
    var id: Int
    var name: String
    var expanded: Bool
    var movies: [DatabaseObject]?
    
    init(id: Int, name: String, expanded: Bool = false) {
        self.id = id
        self.name = name
        self.expanded = expanded
    }
    
    func setMovies(_ movies: [DatabaseObject]) {
        self.movies = movies
    }
    
}
