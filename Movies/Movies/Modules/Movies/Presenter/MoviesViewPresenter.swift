//
//  MoviesViewPresenter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol MoviesPresenter {
    func viewDidLoad()
    func getSortedList(_ type: SortType)
    func getItem(for index: Int) -> MovieModel
    func getItemsCount(hasLoader: Bool) -> Int
    func getNextPage(sort type: SortType)
    func search(text: String, completion: EmptyBlock?)
    func stopSearch()
    func didSelectItem(at index: Int)
}

final class MoviesViewPresenter {
    
    //MARK: - Properties
    private weak var view: MoviesView!
    private let dataManager: DefaultMoviesRepository
    private let router: DefaultMoviesRouter
    private var isLoading: Bool = false
    private var searchWorkItem: DispatchWorkItem?
    private var searchText: String = .empty
    private var genres = [GenreModel]()
    private let loader: Int = 1
    private var isSearchActive: Bool {
        return !searchText.isEmpty
    }
    
    private var movies = [MovieModel]() {
        didSet {
            guard !movies.isEmpty else { return }
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
    
    //MARK: - Life Cycle
    init(view: MoviesView,
         dataManager: DefaultMoviesRepository,
         router: DefaultMoviesRouter) {
        self.view = view
        self.dataManager = dataManager
        self.router = router
    }
    
    deinit {
        removeNetworkStateObserver()
    }
    
    //MARK: - Private methods
    private func getGenres(completion: EmptyBlock? = nil) {
        dataManager.fetchGenres { [weak self] result in
            switch result {
            case .success(let genres):
                self?.genres = genres
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
            self.getMovies(sortType: .popular, hasNextPage: false)
        }
    }
    
    private func getSearchResults(hasNextPage: Bool, completion: EmptyBlock? = nil) {
        searchWorkItem?.cancel()
        let newSearchWorkItem = DispatchWorkItem {
            guard !self.isLoading else { return }
            var page = 1
            if hasNextPage {
                guard let currentPage = self.list.last?.page,
                      let totalPages = self.list.last?.totalPages,
                      currentPage < totalPages else { return }
                page = currentPage 
                page.increment()
            }
            self.isLoading = true
            self.dataManager.search(self.searchText, page: page, genres: self.genres) { [weak self] result in
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let movies):
                    movies.isEmpty ?
                    self.view.updateWithEmptySearchResults(for: self.searchText) :
                    self.searchResults.append(contentsOf: movies)
                case .failure(let error):
                    self.view.showError(with: error.localizedDescription)
                }
                completion?()
            }
        }
        searchWorkItem = newSearchWorkItem
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: newSearchWorkItem)
    }
    
    private func getMovies(sortType: SortType, hasNextPage: Bool, completion: EmptyBlock? = nil) {
        guard !isLoading else { return }
        var page = 1
        if hasNextPage {
            guard let currentPage = list.last?.page,
                  let totalPages = list.last?.totalPages,
                  currentPage < totalPages else { return }
            page = currentPage
            page.increment()
        }
        isLoading = true
        dataManager.fetch(page: page, genres: self.genres, sortType: sortType) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success(let movies):
                self?.movies += movies
                completion?()
            case .failure(let error):
                self?.view.showError(with: error.localizedDescription)
            }
        }
    }
    
    @objc private func networkStatusChanged() {
        view.updateWithNetworkStatus(ReachabilityManager.shared.isNetworkAvailable)
        movies.removeAll()
        getData()
        if !ReachabilityManager.shared.isNetworkAvailable {
            view.showError(with: NetworkError.offline.errorDescription)
        }
    }
    
    private func addNetworkStateObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkStatusChanged),
                                               name: .networkStatusChanged,
                                               object: nil)
    }
    
    private func removeNetworkStateObserver() {
        NotificationCenter.default.removeObserver(self,
                                                  name: .networkStatusChanged,
                                                  object: nil)
    }
    
}

//MARK: - MoviesPresenterProtocol
extension MoviesViewPresenter: MoviesPresenter {
    func viewDidLoad() {
        addNetworkStateObserver()
        getData()
    }
    
    func getSortedList(_ type: SortType) {
        movies.removeAll()
        getMovies(sortType: type, hasNextPage: false) {
            DispatchQueue.main.async {
                self.view.scrollToTop()
            }
        }
    }
    
    func getItem(for index: Int) -> MovieModel {
        searchResults.isEmpty ? movies[index] : searchResults[index]
    }
    
    func getItemsCount(hasLoader: Bool) -> Int {
        if !hasLoader {
            return list.count
        } else {
            if list.isEmpty {
                return .zero
            } else if let currentPage = list.last?.page,
                      let totalPages = list.last?.totalPages,
                      currentPage < totalPages {
                return list.count + loader
            } else {
                return list.count
            }
        }
    }
    
    func getNextPage(sort type: SortType) {
        if ReachabilityManager.shared.isNetworkAvailable {
            isSearchActive ?
            getSearchResults(hasNextPage: true) :
            getMovies(sortType: type, hasNextPage: true)
        }
    }
    
    func search(text: String, completion: EmptyBlock?) {
        guard !text.isEmpty else {
            stopSearch()
            return
        }
        searchText = text
        searchResults.removeAll()
        getSearchResults(hasNextPage: false, completion: completion)
    }
    
    func stopSearch() {
        searchWorkItem?.cancel()
        searchResults.removeAll()
        searchText = .empty
    }
    
    func didSelectItem(at index: Int) {
        let movie = getItem(for: index)
        ReachabilityManager.shared.isNetworkAvailable ?
        router.showDetails(for: movie) :
        view.showError(with: NetworkError.offline.errorDescription)
    }
}
