import Alamofire

class Client {

    private func injectParams(_ params: Parameters) -> Parameters {
        var res = params
        res["api_key"] = ConfigurationService.themoviedbKey
        
        return res
    }
    
    func request(path: String, params: Parameters = [:]) -> DataRequest {
        let urlString = "https://api.themoviedb.org/3\(path)"
        return AF.request(urlString, parameters: injectParams(params))
    }
    
}
