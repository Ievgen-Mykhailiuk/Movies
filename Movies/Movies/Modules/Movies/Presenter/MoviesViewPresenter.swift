//
//  MoviesViewPresenter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol MoviesPresenter {
    func viewDidLoad()
    func getSortedMovies(_ type: SortType)
    func getMovie(for index: Int) -> MovieModel
    func getItemsCount() -> Int
    func getNextPage(sort type: SortType)
    func search(text: String)
    func stopSearch()
    func movieTapped(at index: Int)
}

final class MoviesViewPresenter {
    
    //MARK: - Properties
    private weak var view: MoviesView!
    private let dataManager: DefaultMoviesRepository
    private let router: DefaultMoviesRouter
    private let minSymbolsToSearch: Int = 2
    private var isLoading: Bool = false
    private var searchWorkItem: DispatchWorkItem?
    private var searchText: String = .empty
    private var genres = [GenreModel]()
    private var movieListTotalPages: Int = .zero
    private var searchResultsTotalPages: Int = .zero
    private var movieListCurrentPage: Int = 1
    private var searchResultsCurrentPage: Int = 1
    
    private var isSearchActive: Bool {
        return !searchText.isEmpty
    }
    
    private var movies = [MovieModel]() {
        didSet {
            updateView()
        }
    }
    
    private var searchResults = [MovieModel]() {
        didSet {
            updateView()
        }
    }
    
    private var list: [MovieModel] {
        return isSearchActive ? searchResults : movies
    }
    
    private var isNetworkAvailable: Bool = true {
        didSet {
            DispatchQueue.main.async {
                self.view.updateWithNetworkStatus(isAvailable: self.isNetworkAvailable)
            }
        }
    }
    
    //MARK: - Life Cycle
    init(view: MoviesView,
         dataManager: DefaultMoviesRepository,
         router: DefaultMoviesRouter) {
        self.view = view
        self.dataManager = dataManager
        self.router = router
    }
    
    //MARK: - Private methods
    private func getGenres(completion: EmptyBlock? = nil) {
        dataManager.fetchGenres { [weak self] result in
            switch result {
            case .success(let data):
                self?.genres = data.genres
            case .failure(let error):
                self?.view.showError(with: error.localizedDescription)
            }
            completion?()
        }
    }
    
    private func updateView() {
        DispatchQueue.main.async {
            self.view.update()
        }
    }
    
    private func getData() {
        getGenres {
            self.getMovies(sortType: .popular, nextPage: false)
        }
    }
    
    private func getCoreData() {
        dataManager.loadFromDataBase { [weak self] result in
            switch result {
            case .success(let movies):
                guard let movies = movies else { return }
                self?.movies = movies
            case .failure(let error):
                self?.view.showError(with: error.localizedDescription)
            }
        }
    }

    private func localSearch() {
        searchResults = movies.filter { $0.title.lowercased().contains(self.searchText.lowercased()) }
    }
    
    private func networkSearch() {
        searchWorkItem?.cancel()
        let newSearchWorkItem = DispatchWorkItem {
            if self.isLoading {
                return
            }
            self.isLoading = true
            self.dataManager.search(page: self.searchResultsCurrentPage, text: self.searchText) { [weak self] result in
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let data):
                    let movies = data.results.map { item in MovieModel.from(networkModel: item, using: self.genres) }
                    self.searchResultsTotalPages = data.totalPages
                    self.searchResultsCurrentPage = data.page
                    self.searchResults.append(contentsOf: movies)
                case .failure(let error):
                    self.view.showError(with: error.localizedDescription)
                }
            }
        }
        searchWorkItem = newSearchWorkItem
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1), execute: newSearchWorkItem)
    }
    
    private func getMovies(sortType: SortType, nextPage: Bool) {
        if isLoading {
            return
        }
        isLoading = true
        dataManager.fetch(page: movieListCurrentPage, sortType: sortType) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let data):
                let movies = data.results.map { item in
                    MovieModel.from(networkModel: item, using: self.genres)
                }
                self.movieListTotalPages = data.totalPages
                self.movieListCurrentPage = data.page
                self.movies += movies
                self.dataManager.saveToDataBase(movies: movies) { error in
                    self.view.showError(with: error.localizedDescription)
                }
            case .failure(let error):
                self.view.showError(with: error.localizedDescription)
            }
        }
    }
    
    @objc private func networkStatusChanged() {
        if ReachabilityManager.shared.isNetworkAvailable {
            isNetworkAvailable = true
        } else {
            isNetworkAvailable = false
            view.showError(with: NetworkError.offline.localizedDescription)
            getCoreData()
        }
    }

    private func startNetworkMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkStatusChanged),
                                               name: .networkStatusChanged,
                                               object: nil)
        ReachabilityManager.shared.start()
    }
    
}

//MARK: - MoviesPresenterProtocol
extension MoviesViewPresenter: MoviesPresenter {
    func viewDidLoad() {
        startNetworkMonitoring()
        getData()
    }
    
    func getSortedMovies(_ type: SortType) {
        movieListCurrentPage = 1
        movies = []
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
        list.count
    }
    
    func getNextPage(sort type: SortType) {
        if isNetworkAvailable {
            if isSearchActive {
                if searchResultsCurrentPage < searchResultsTotalPages {
                    searchResultsCurrentPage.increment()
                    networkSearch()
                }
            } else {
                if movieListCurrentPage < movieListTotalPages {
                    movieListCurrentPage.increment()
                    getMovies(sortType: type, nextPage: true)
                }
            }
        }
    }
    
    func search(text: String) {
        if text.count >= minSymbolsToSearch {
            searchResultsCurrentPage = 1
            searchText = text
            searchResults = []
            isNetworkAvailable ?
            networkSearch() : localSearch()
        } else {
            stopSearch()
        }
    }
    
    func stopSearch() {
        searchWorkItem?.cancel()
        searchResults = []
        searchText = .empty
    }
    
    func movieTapped(at index: Int) {
        let movie = getMovie(for: index)
        if isNetworkAvailable {
            router.showDetails(movieID: movie.id)
        } else {
            view.showError(with: NetworkError.offline.localizedDescription)
        }
    }
}
