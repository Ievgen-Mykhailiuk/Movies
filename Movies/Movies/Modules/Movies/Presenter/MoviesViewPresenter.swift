//
//  MoviesViewPresenter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation
import UIKit

protocol MoviesPresenter {
    func viewDidLoad(isNetworkAvailable: Bool)
    func getSortedMovies(_ type: SortType)
    func getMovie(for index: Int) -> MovieModel
    func getItemsCount() -> Int
    func nextPage(sort type: SortType)
    func search(text: String, network: Bool)
    func stopSearch()
    func movieTapped(at index: Int)
    func modelIsReadyToSave(movie: MovieModel, poster: UIImage?)
}

enum SortType {
    case byPopularity
    case byVotesCount
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
    private var pageCounter: Int = 1
    private var timer: Timer?
    private var searchIsActive: Bool = false
    private var searchText: String = .empty
    
    //MARK: - Life Cycle
    init(view: MoviesView,
         networkManager: MoviesNetworkManager,
         dataBaseManager: CoreDataService,
         router: DefaultMoviesRouter) {
        self.view = view
        self.networkManager = networkManager
        self.dataBaseManager = dataBaseManager
        self.router = router
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
    
    private func useNetworkData() {
        getGenres()
        getSortedMovies(.byPopularity)
    }
    
    private func useCoreData() {
        dataBaseManager.loadAll { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                guard let movies = movies else { return }
                self.movies = movies
            case .failure(let error):
                self.view.didFailWithError(error: error.localizedDescription)
            }
        }
    }
    
    private func resetPageCounter() {
        pageCounter = 1
    }
    
    private func nextPage() {
        pageCounter += 1
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
                               votesAverage: String(format: "%.1f", item.votesAverage),
                               votesCount: String(item.voteCount),
                               overview: item.overview)
        return movie
    }
    
    private func localSearch() {
        searchIsActive = true
        let filtred = self.movies.filter { $0.title.lowercased().contains(self.searchText.lowercased()) }
        self.searchResults = filtred
    }
    
    private func networkSearch() {
        timer?.invalidate()
        searchIsActive = true
        timer = .scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.networkManager.search(page: self.pageCounter, text: self.searchText) { result in
                switch result {
                case .success(let data):
                    let movies = data.results
                        .filter { $0.title.lowercased().contains(self.searchText.lowercased()) }
                        .map { item in self.convertToModel(item: item) }
                    self.searchResults.append(contentsOf: movies)
                case .failure(let error):
                    self.view.didFailWithError(error: error.localizedDescription)
                }
            }
        }
    }
    
    private func getMovies(sortType: SortType, nextPage: Bool) {
        networkManager.fetch(page: pageCounter, sortType: sortType) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                let movies = data.results.map { item in
                    self.convertToModel(item: item)
                }
                switch nextPage {
                case true:
                    self.movies += movies
                case false:
                    self.movies = movies
                }
            case .failure(let error):
                self.view.didFailWithError(error: error.localizedDescription)
            }
        }
    }
}

//MARK: - MoviesPresenterProtocol
extension MoviesViewPresenter: MoviesPresenter {
    func viewDidLoad(isNetworkAvailable: Bool) {
        isNetworkAvailable ? useNetworkData() : useCoreData()
    }
    
    func getSortedMovies(_ type: SortType) {
        resetPageCounter()
        getMovies(sortType: type, nextPage: false)
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
        nextPage()
        searchIsActive ?  networkSearch() : getMovies(sortType: type, nextPage: true)
    }
    
    func search(text: String, network: Bool) {
        resetPageCounter()
        searchText = text
        network ? networkSearch() : localSearch()
    }
    
    func stopSearch() {
        timer?.invalidate()
        searchIsActive = false
        searchResults = []
        searchText = .empty
        resetPageCounter()
    }
    
    func movieTapped(at index: Int) {
        let movie = getMovie(for: index)
        router.showDetails(movieID: movie.id)
    }
    
    func modelIsReadyToSave(movie: MovieModel, poster: UIImage?) {
        dataBaseManager.save(movie: movie, poster: poster) { [weak self] error in
            guard let self = self else { return }
            self.view.didFailWithError(error: error.localizedDescription)
        }
    }
}
