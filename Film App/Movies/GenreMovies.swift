struct GenreMovies {
    var name: String
    var movies: [DatabaseObject]
    var expanded: Bool
    
    init(name: String, movies: [DatabaseObject], expanded: Bool = false) {
        self.name = name
        self.movies = movies
        self.expanded = expanded
    }
    
}
