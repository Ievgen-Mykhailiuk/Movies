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
    
    //MARK: - Properties
    private let networkService: NetworkService
    private let coreDataService: CoreDataService
    
    //MARK: - Life Cycle
    init(networkService: NetworkService = DefaultNetworkService(),
         coreDataService: CoreDataService = DefaultCoreDataService.shared) {
        self.networkService = networkService
        self.coreDataService = coreDataService
    }
    
    //MARK: - Private Methods
    private func moviesFrom(_ data: MovieResponse, using genres: [GenreModel]) -> [MovieModel] {
        return data.results.compactMap { networkModel in
            var movie = MovieModel.from(networkModel: networkModel)
            let genres = networkModel.genreIDS.compactMap { id in
                genres.first(where: { $0.id == id })?.name
            }
            movie.page = data.page
            movie.totalPages = data.totalPages
            movie.genres = genres
            return movie
        }
    }
    
    //MARK: - Protocol Methods
    func search(page: Int, genres: [GenreModel], text: String, completion: @escaping MoviesBlock) {
        networkService.cancelRequest()
        networkService.request(from: .search(page: page, text: text)) { (result: Result<MovieResponse, Error>) in
            switch result {
            case .success(let data):
                let movies = self.moviesFrom(data, using: genres)
                self.coreDataService.save(movies: movies) { error in
                    completion(.failure(error))
                }
                completion(.success(movies))
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
                    let movies = self.moviesFrom(data, using: genres)
                    self.coreDataService.save(movies: movies) { error in
                        completion(.failure(error))
                    }
                    completion(.success(movies))
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
