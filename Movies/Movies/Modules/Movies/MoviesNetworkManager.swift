//
//  MoviesAPIService.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol MoviesNetworkService {
    func fetch(page: Int, sortType: SortType, completion: @escaping MoviesBlock)
    func fetchGenres(completion: @escaping GenresBlock)
    func search(page: Int, text: String, completion: @escaping MoviesBlock)
}

final class MoviesNetworkManager: BaseNetworkService, MoviesNetworkService {
    func search(page: Int, text: String, completion: @escaping MoviesBlock) {
        request(from: .search(page: page, text: text), httpMethod: .get) {
            (result: Result<MovieResponse, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchGenres(completion: @escaping GenresBlock) {
        request(from: .genres, httpMethod: .get) { (result: Result<Genres, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetch(page: Int, sortType: SortType, completion: @escaping MoviesBlock) {
        var endpoint: EndPoint = .popular(page: page)
        switch sortType {
        case .byDefault:
            endpoint = .popular(page: page)
        case .byVotes:
            endpoint = .votes(page: page)
        case .byTrend:
            endpoint = .trend(page: page)
        }
        request(from: endpoint, httpMethod: .get) {
            (result: Result<MovieResponse, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
