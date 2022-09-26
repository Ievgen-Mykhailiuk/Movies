//
//  BaseNetworkService.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation
import Alamofire

protocol NetworkService {
    func request<T: Decodable>(from endPoint: EndPoint,
                             httpMethod: BaseNetworkService.HttpMethod,
                             completion: @escaping (Result<T, Error>) -> Void)
}

class BaseNetworkService: NetworkService {
    
    //MARK: - Http methods
    enum HttpMethod:  String {
        case get
        var method: String { rawValue.uppercased() }
    }

    //MARK: - Network request method
    func request<T: Decodable>(from endPoint: EndPoint,
                             httpMethod: HttpMethod,
                             completion: @escaping (Result<T, Error>) -> Void) {

        guard let url = endPoint.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.method
        AF.request(request).validate(statusCode: 200..<300).responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
