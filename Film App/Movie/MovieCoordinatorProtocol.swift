protocol MovieCoordinator: class {
    func showMovie(id: Int, type: MediaType)
    func playVideo(withId id: String)
    func showPersonProfile(withId id: Int)
}

// Optional methods
extension MovieCoordinator {
    func playVideo(withId id: String) {}
    func showPersonProfile(withId id: Int) {}
}
