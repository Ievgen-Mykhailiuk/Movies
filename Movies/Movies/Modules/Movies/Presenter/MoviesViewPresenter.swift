//
//  MoviesViewPresenter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation
import UIKit

protocol MoviesPresenter {
    func viewDidLoad(network: Bool)
    func getMovies(sorted type: SortType)
    func getMovie(for index: Int) -> MovieModel
    func getItemsCount() -> Int
    func nextPage(sort type: SortType)
    func search(text: String, network: Bool)
    func stopSearch()
    func movieTapped(at index: Int)
    func save(movie: MovieModel, poster: UIImage?)
}

enum SortType {
    case byDefault
    case byVotes
    case byTrend
}

final class MoviesViewPresenter {
    
    //MARK: - Properties
    private weak var view: MoviesView!
    private let networkManager: MoviesNetworkManager
    private let dataBaseManager: CoreDataService
    private let router: DefaultMoviesRouter
    private var movies = [MovieModel]() {
        didSet {
            view.update()
        }
    }
    private var searchResults = [MovieModel]() {
        didSet {
            view.update()
        }
    }
    private var genres = [GenreModel]()
    private var page: Int = 1
    private var timer: Timer?
    private var searchIsActive: Bool = false
    
    //MARK: - Life Cycle
    init(view: MoviesView,
         networkManager: MoviesNetworkManager,
         dataBaseManager: CoreDataService,
         router: DefaultMoviesRouter
            ) {
        self.view = view
        self.networkManager = networkManager
        self.router = router
        self.dataBaseManager = dataBaseManager
    }
    
    //MARK: - Private mwethods
    private func getGenres() {
        networkManager.fetchGenres { result in
            switch result {
            case .success(let data):
                self.genres = data.genres
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getNetworkData() {
        getGenres()
        getMovies(sorted: .byDefault)
    }
    
    private func getDataBaseData() {
        dataBaseManager.getAllMovies { result in
            if let movies = result {
                self.movies = movies
            }
        }
    }
    
    private func convertToModel(item: MovieData) -> MovieModel {
        let genres = item.genreIDS.compactMap { id in
            self.genres.first(where: { $0.id == id })?.name
        }
        let releaseYear: String = .getYear(stringDate: item.releaseDate)
        let movie = MovieModel(genres: genres,
                               id: item.id,
                               popularity: String(item.popularity),
                               posterPath: item.posterPath,
                               releaseYear: releaseYear,
                               title: item.title,
                               votesAverage: String(item.votesAverage),
                               votesCount: String(item.voteCount),
                               overview: item.overview)
        return movie
    }
    
    private func localFilter(with text: String) {
        searchIsActive = true
        let filtred = self.movies.filter { $0.title.lowercased().contains(text.lowercased()) }
        self.searchResults = filtred
    }
    
    private func networkFilter(with text: String) {
        page = 1
        timer?.invalidate()
        searchIsActive = true
        timer = .scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.networkManager.search(page: self.page, text: text) { result in
                switch result {
                case .success(let data):
                    let movies = data.results
                        .filter { $0.title.lowercased().contains(text.lowercased()) }
                        .map { item in self.convertToModel(item: item) }
                    self.searchResults = movies
                case .failure(let error):
                    self.view.didFailWithError(error: error.localizedDescription)
                }
            }
        }
    }
}

//MARK: - MoviesPresenterProtocol
extension MoviesViewPresenter: MoviesPresenter {
    func viewDidLoad(network: Bool) {
        network ? getNetworkData() : getDataBaseData()
//                dataBaseManager.deleteAll()
    }
    
    func getMovies(sorted type: SortType) {
        page = 1
        networkManager.fetch(page: page, sortType: type) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                let movies = data.results.map { item in
                    self.convertToModel(item: item)
                }
                self.movies = movies
//                self.dataBaseManager.saveMovies(movies: movies)
            case .failure(let error):
                self.view.didFailWithError(error: error.localizedDescription)
            }
        }
    }
    
    func getMovie(for index: Int) -> MovieModel {
        if searchResults.isEmpty {
            return movies[index]
        } else {
            return searchResults[index]
        }
    }
    
    func getItemsCount() -> Int {
        if searchIsActive {
            return searchResults.count
        } else {
            return movies.count
        }
    }
    
    func nextPage(sort type: SortType) {
        page += 1
        networkManager.fetch(page: page, sortType: type) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                var movies = [MovieModel]()
                data.results.forEach { item in
                    movies.append(self.convertToModel(item: item))
                }
                self.searchIsActive ?
                self.searchResults.append(contentsOf: movies) : self.movies.append(contentsOf: movies)
//                self.dataBaseManager.saveMovies(movies: movies)
            case .failure(let error):
                self.view.didFailWithError(error: error.localizedDescription)
            }
        }
    }
    
    func search(text: String, network: Bool) {
        network ?
        networkFilter(with: text) : localFilter(with: text)
    }
    
    func stopSearch() {
        timer?.invalidate()
        searchIsActive = false
        searchResults = []
    }
    
    func movieTapped(at index: Int) {
        let movie = getMovie(for: index)
        router.showDetails(movieID: movie.id)
    }
    
    func save(movie: MovieModel, poster: UIImage?) {
        dataBaseManager.saveMovie(movie: movie, poster: poster)
    }
}
