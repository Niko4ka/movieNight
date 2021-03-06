import Alamofire

final class Client {
    
    enum Result<T> {
        case success(T)
        case error
    }
    
    private let themoviedbKey = "81c0943d1596e1cc2b1c8de9e9ba8945"
    let googleKey = "AIzaSyAluG5wfH3vDhket7F2b2pFAzdgKH6F4mk"
    
    static let shared = Client()
    
    private init() {}

    /// Returns Parameters with apiKey
    ///
    /// - Parameter params: request parameters
    /// - Returns: Parameters with apiKey
    private func injectParams(_ params: Parameters) -> Parameters {
        var res = params
        res["api_key"] = themoviedbKey
        return res
    }
    
    func request(path: String, params: Parameters = [:]) -> DataRequest {
        let urlString = "https://api.themoviedb.org/3\(path)"
        return AF.request(urlString, parameters: injectParams(params))
    }

}
