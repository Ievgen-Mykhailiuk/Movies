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
                               completion: @escaping (Result<T, Error>) -> Void)
    func cancelRequest()
}

final class DefaultNetworkService: NetworkService {
    
    //MARK: - Properties
    private var request: DataRequest?
    
    //MARK: - Network request & cancel methods
    func request<T: Decodable>(from endPoint: EndPoint,
                               completion: @escaping (Result<T, Error>) -> Void) {
        
        request = AF.request(endPoint.urlString,
                             method: endPoint.httpMethod,
                             parameters: endPoint.parameters,
                             encoding: endPoint.encoding)
        .validate(statusCode: 200..<300)
        .responseDecodable(of: T.self) { response in
            
            switch response.result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func cancelRequest() {
        request?.cancel()
    }
    
}
