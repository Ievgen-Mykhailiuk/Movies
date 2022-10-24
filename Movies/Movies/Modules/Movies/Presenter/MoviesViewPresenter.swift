//
//  MoviesViewPresenter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol MoviesPresenter {
    func viewDidLoad()
    func getSortedList(_ type: SortType)
    func getItem(for index: Int) -> MovieModel
    func getItemsCount() -> Int
    func getNextPage(sort type: SortType)
    func search(text: String)
    func stopSearch()
    func itemSelected(at index: Int)
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
    
    //MARK: - Life Cycle
    init(view: MoviesView,
         dataManager: DefaultMoviesRepository,
         router: DefaultMoviesRouter) {
        self.view = view
        self.dataManager = dataManager
        self.router = router
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .networkStatusChanged, object: nil)
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
            self.getMovies(sortType: .popular, nextPage: false)
        }
    }
    
    private func localSearch() {
        searchResults = movies.filter { $0.title.lowercased().contains(self.searchText.lowercased()) }
    }
    
    private func networkSearch(nextPage: Bool) {
        searchWorkItem?.cancel()
        let newSearchWorkItem = DispatchWorkItem {
            guard !self.isLoading else { return }
            var page = 1
            if nextPage {
                if let currentPage = self.list.last?.page, let totalPages = self.list.last?.totalPages, currentPage < totalPages {
                    page = currentPage
                    page.increment()
                } else {
                    return
                }
            }
            self.isLoading = true
            self.dataManager.search(page: page, genres: self.genres, text: self.searchText) { [weak self] result in
                self?.isLoading = false
                switch result {
                case .success(let movies):
                    self?.searchResults.append(contentsOf: movies)
                case .failure(let error):
                    self?.view.showError(with: error.localizedDescription)
                }
            }
        }
        searchWorkItem = newSearchWorkItem
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1), execute: newSearchWorkItem)
    }
    
    private func getMovies(sortType: SortType, nextPage: Bool, completion: EmptyBlock? = nil) {
        guard !isLoading else { return }
        var page = 1
        if nextPage {
            if let currentPage = self.list.last?.page, let totalPages = self.list.last?.totalPages, currentPage < totalPages {
                page = currentPage
                page.increment()
            } else {
                return
            }
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
            DispatchQueue.main.async {
                self.view.showError(with: NetworkError.offline.errorDescription)
            }
        }
    }

    private func startNetworkMonitoring() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkStatusChanged),
                                               name: .networkStatusChanged,
                                               object: nil)
    }
    
}

//MARK: - MoviesPresenterProtocol
extension MoviesViewPresenter: MoviesPresenter {
    func viewDidLoad() {
        startNetworkMonitoring()
        getData()
    }
    
    func getSortedList(_ type: SortType) {
        movies.removeAll()
        getMovies(sortType: type, nextPage: false) {
            DispatchQueue.main.async {
                self.view.scrollToTop()
            }
        }
    }
    
    func getItem(for index: Int) -> MovieModel {
        searchResults.isEmpty ? movies[index] : searchResults[index]
    }
    
    func getItemsCount() -> Int {
        list.count
    }
    
    func getNextPage(sort type: SortType) {
        if ReachabilityManager.shared.isNetworkAvailable {
            isSearchActive ? networkSearch(nextPage: true) : getMovies(sortType: type, nextPage: true)
        }
    }
    
    func search(text: String) {
        if text.count >= minSymbolsToSearch {
            searchText = text
            searchResults.removeAll()
            ReachabilityManager.shared.isNetworkAvailable ? networkSearch(nextPage: false) : localSearch()
        } else {
            stopSearch()
        }
    }
    
    func stopSearch() {
        searchWorkItem?.cancel()
        searchResults.removeAll()
        searchText = .empty
    }
    
    func itemSelected(at index: Int) {
        let movie = getItem(for: index)
        ReachabilityManager.shared.isNetworkAvailable ?
        router.showDetails(movieID: movie.id) :
        view.showError(with: NetworkError.offline.errorDescription)
    }
}
