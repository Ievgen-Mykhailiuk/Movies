//
//  DetailsAPIService.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol DetailsNetworkService {
    func fetchDetails(movieID: Int, completion: @escaping DetailsBlock)
    func fetchTrailerPath(movieID: Int, completion: @escaping TrailerBlock)
}

final class DetailsAPIService: BaseNetworkService, DetailsNetworkService {
    func fetchDetails(movieID: Int, completion: @escaping DetailsBlock) {
        request(from: .details(movieID: movieID), httpMethod: .get) { (result: Result<DetailsData, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchTrailerPath(movieID: Int, completion: @escaping TrailerBlock) {
        request(from: .trailerPath(movieID: movieID), httpMethod: .get) { (result: Result<TrailerResponse, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
