import Alamofire

extension Client {
    
    func loadImage(url: URLConvertible, completion: @escaping (Result<Data>)->Void) {
        AF.request(url).responseData { (response) in
            if let data = response.value {
                completion(.success(data))
            } else {
                completion(.error)
            }
        }
    }
}
