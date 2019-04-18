protocol ListRequest {
    var mediaType: MediaType { get }
    var rawValue: (type: ListRequests, title: String, path: String) { get }
}

enum ListRequests {
    case moviesCategories
    case search
    case similar
    case movieGenres
}

enum MoviesCategoriesListRequest: ListRequest {
    
    case nowPlayingMovies
    case popularMovies
    case upcomingMovies
    
    var mediaType: MediaType {
        return .movie
    }
    
    var rawValue: (type: ListRequests, title: String, path: String) {
        switch self {
        case .nowPlayingMovies: return (type: .moviesCategories, title: "Now in Cinemas", path: "/movie/now_playing")
        case .popularMovies: return (type: .moviesCategories, title: "Popular Movies", path: "/movie/popular")
        case .upcomingMovies: return (type: .moviesCategories, title: "Upcoming Movies", path: "/movie/upcoming")
        }
    }
    
}

enum SearchListRequest: ListRequest {
    
    case movie(keyword: String)
    case tvShow(keyword: String)
    case person(keyword: String)
    
    var mediaType: MediaType {
        switch self {
        case .movie: return .movie
        case .tvShow: return .tvShow
        case .person: return .person
        }
    }
    
    var keyword: String {
        switch self {
        case .movie(let keyword): return keyword
        case .tvShow(let keyword): return keyword
        case .person(let keyword): return keyword
        }
    }
    
    var rawValue: (type: ListRequests, title: String, path: String) {
        switch self {
        case .movie: return (type: .search, title: "\"\(keyword)\" movies", path: "/search/movie")
        case .tvShow: return (type: .search, title: "\"\(keyword)\" TV shows", path: "/search/tv")
        case .person: return (type: .search, title: "\"\(keyword)\" persons", path: "/search/person")
        }
    }
}

enum SimilarListRequest: ListRequest {
    
    case movie(name: String, id: Int)
    case tv(name: String, id: Int)
    
    var mediaType: MediaType {
        switch self {
        case .movie: return .movie
        case .tv: return .tvShow
        }
    }
    
    var rawValue: (type: ListRequests, title: String, path: String) {
        switch self {
        case .movie(let name, let id): return (type: .similar, title: "Similar to \"\(name)\"", path: "/movie/\(id)/similar")
        case .tv(let name, let id): return (type: .similar, title: "Similar to \"\(name)\"", path: "/tv/\(id)/similar")
        }
    }
}

struct MovieGenresListRequest: ListRequest {
    
    var rawValue: (type: ListRequests, title: String, path: String)
    var mediaType: MediaType = .movie
    
    init(genreName: String, genreId: Int) {
        self.rawValue = (type: .movieGenres, title: genreName, path: "\(genreId)")
    }
}
