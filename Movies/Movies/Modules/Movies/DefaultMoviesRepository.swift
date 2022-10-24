//
//  MoviesAPIService.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol MoviesRepository {
    func fetch(page: Int, genres: [GenreModel], sortType: SortType, completion: @escaping MoviesBlock)
    func fetchGenres(completion: @escaping GenresBlock)
    func search(page: Int, genres: [GenreModel], text: String, completion: @escaping MoviesBlock)
}

final class DefaultMoviesRepository: MoviesRepository {
    
    private let networkService: NetworkService
    private let coreDataService: CoreDataService
    
    init(networkService: NetworkService = DefaultNetworkService(),
         coreDataService: CoreDataService = DefaultCoreDataService.shared) {
        self.networkService = networkService
        self.coreDataService = coreDataService
    }
    
    func search(page: Int, genres: [GenreModel], text: String, completion: @escaping MoviesBlock) {
        networkService.cancelRequest()
        networkService.request(from: .search(page: page, text: text)) { (result: Result<MovieResponse, Error>) in
            switch result {
            case .success(let data):
                let movies = MovieModel.from(networkResponse: data, using: genres)
                completion(.success(movies))
                for movie in movies {
                    self.coreDataService.save(movie: movie) { error in
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchGenres(completion: @escaping GenresBlock) {
        networkService.request(from: .genres) { (result: Result<GenresData, Error>) in
            switch result {
            case .success(let data):
                completion(.success(data.genres))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetch(page: Int, genres: [GenreModel], sortType: SortType, completion: @escaping MoviesBlock) {
        if ReachabilityManager.shared.isNetworkAvailable {
            networkService.request(from: .movies(sortType: sortType, page: page)) { (result: Result<MovieResponse, Error>)  in
                switch result {
                case .success(let data):
                    let movies = MovieModel.from(networkResponse: data, using: genres)
                    completion(.success(movies))
                    for movie in movies {
                        self.coreDataService.save(movie: movie) { error in
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            coreDataService.load { (result: Result<[MovieModel], Error>) in
                switch result {
                case .success(let movies):
                    completion(.success(movies))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
}
