import Alamofire

class Client {
    let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private func injectParams(_ params: Parameters) -> Parameters {
        var res = params
        res["api_key"] = apiKey
        
        return res
    }
    
    func request(path: String, params: Parameters = [:]) -> DataRequest {
        let urlString = "https://api.themoviedb.org/3\(path)"
        return AF.request(urlString, parameters: injectParams(params))
    }
    
}
