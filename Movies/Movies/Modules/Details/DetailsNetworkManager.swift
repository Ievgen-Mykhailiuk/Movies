//
//  DetailsNetworkManager.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol DetailsNetworkService {
    func fetchDetails(movieID: Int, completion: @escaping DetailsBlock)
    func fetchTrailerID(movieID: Int, completion: @escaping TrailerBlock)
}

final class DetailsNetworkManager: BaseNetworkService, DetailsNetworkService {
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
    
    func fetchTrailerID(movieID: Int, completion: @escaping TrailerBlock) {
        request(from: .trailerID(movieID: movieID), httpMethod: .get) { (result: Result<TrailerResponse, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
