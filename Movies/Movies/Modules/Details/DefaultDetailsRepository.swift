//
//  DetailsNetworkManager.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol DetailsRepository {
    func fetchDetails(movieID: Int, completion: @escaping DetailsBlock)
    func fetchTrailerID(movieID: Int, completion: @escaping TrailerBlock)
}

final class DefaultDetailsRepository: DetailsRepository {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService = DefaultNetworkService()) {
        self.networkService = networkService
    }
    
    func fetchDetails(movieID: Int, completion: @escaping DetailsBlock) {
        networkService.request(from: .details(movieID: movieID)) { (result: Result<DetailsData, Error>) in
            switch result {
            case .success(let data):
                let details = DetailsModel.from(networkModel: data)
                completion(.success(details))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchTrailerID(movieID: Int, completion: @escaping TrailerBlock) {
        networkService.request(from: .trailerID(movieID: movieID)) { (result: Result<TrailerData, Error>) in
            switch result {
            case .success(let data):
                let trailer = data.results.first(where: { $0.type.lowercased() == "trailer" })
                completion(.success(trailer?.key))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
