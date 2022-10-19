//
//  MoviesAPIService.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol MoviesRepository {
    func fetch(page: Int, sortType: SortType, completion: @escaping MoviesBlock)
    func fetchGenres(completion: @escaping GenresBlock)
    func search(page: Int, text: String, completion: @escaping MoviesBlock)
    func loadFromDataBase(completion: @escaping DataBaseBlock)
    func saveToDataBase(movies: [MovieModel], completion: @escaping ErrorBlock)
}

final class DefaultMoviesRepository: MoviesRepository {
    
    private let networkService: NetworkService
    private let coreDataService: CoreDataService
    
    init(networkService: NetworkService = DefaultNetworkService(),
         coreDataService: CoreDataService = DefaultCoreDataService.shared) {
        self.networkService = networkService
        self.coreDataService = coreDataService
    }
    
    func search(page: Int, text: String, completion: @escaping MoviesBlock) {
        networkService.request(from: .search(page: page, text: text), completion: completion)
    }

    func fetchGenres(completion: @escaping GenresBlock) {
        networkService.request(from: .genres, completion: completion)
    }

    func fetch(page: Int, sortType: SortType, completion: @escaping MoviesBlock) {
        networkService.request(from: .movies(sortType: sortType, page: page), completion: completion)
    }
    
    func loadFromDataBase(completion: @escaping DataBaseBlock) {
        coreDataService.load(completion: completion)
    }
    
    func saveToDataBase(movies: [MovieModel], completion: @escaping ErrorBlock) {
        for movie in movies {
            coreDataService.save(movie: movie, completion: completion)
        }
    }
    
}
