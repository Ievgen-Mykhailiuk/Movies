//
//  MoviesViewPresenter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol MoviesPresenter {
    func viewDidLoad()
    func fetchMovies(sort type: SortType)
    func getMovie(for index: Int) -> MovieModel
    func getItemsCount() -> Int
    func nextPage(sort type: SortType)
    func search(text: String)
    func stopSearch()
    func movieTapped(at index: Int)
}

enum SortType {
    case byDefault
    case byVotes
    case byTrend
}

final class MoviesViewPresenter {
    
    //MARK: - Properties
    private weak var view: MoviesView!
    private let apiManager: MoviesAPIService
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
         apiManager: MoviesAPIService,
         router: DefaultMoviesRouter) {
        self.view = view
        self.apiManager = apiManager
        self.router = router
    }
    
    //MARK: - Private mwethods
    private func fetchGenres() {
        apiManager.fetchGenres { result in
            switch result {
            case .success(let data):
                self.genres = data.genres
            case .failure(let error):
                print(error)
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
                               popularity: item.popularity,
                               posterPath: item.posterPath ?? .empty,
                               releaseYear: releaseYear,
                               title: item.title,
                               voteAverage: item.voteAverage,
                               voteCount: item.voteCount,
                               overview: item.overview)
        return movie
    }
   
    private func getYear(from date: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let releaseDate = formatter.date(from: date)  ?? Date()
        return Calendar.current.component(.year, from: releaseDate)
    }
}

//MARK: - MoviesPresenterProtocol
extension MoviesViewPresenter: MoviesPresenter {
    func viewDidLoad() {
        fetchGenres()
        fetchMovies(sort: .byDefault)
    }
    
    func fetchMovies(sort type: SortType) {
        page = 1
        apiManager.fetch(page: page, sortType: type) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                let movies = data.results.map { item in
                    self.convertToModel(item: item)
                }
                self.movies = movies
            case .failure(let error):
                self.view.didFailWithError(error: error.localizedDescription)
            }
        }
    }
    
    func getMovie(for index: Int) -> MovieModel {
         if searchIsActive {
            return searchResults[index]
        } else {
            return movies[index]
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
        apiManager.fetch(page: page, sortType: type) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                data.results.forEach { item in
                    self.searchIsActive ? self.searchResults.append(self.convertToModel(item: item)) : self.movies.append(self.convertToModel(item: item))
                }
            case .failure(let error):
                self.view.didFailWithError(error: error.localizedDescription)
            }
        }
    }
    
    func search(text: String) {
        if text.count >= 2 {
            page = 1
            timer?.invalidate()
            searchIsActive = true
            timer = .scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.apiManager.search(page: self.page, text: text) { result in
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
        } else {
            stopSearch()
        }
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
}
