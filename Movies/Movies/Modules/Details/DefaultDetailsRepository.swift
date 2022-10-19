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
        networkService.request(from: .details(movieID: movieID), completion: completion)
    }
    
    func fetchTrailerID(movieID: Int, completion: @escaping TrailerBlock) {
        networkService.request(from: .trailerID(movieID: movieID), completion: completion)
    }
    
}
