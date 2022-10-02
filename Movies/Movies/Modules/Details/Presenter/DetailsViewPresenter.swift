//
//  DetailsViewPresenter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol DetailsPresenter {
    func viewDidLoad()
    func playButtonTapped()
    func posterTapped()
}

final class DetailsViewPresenter {
    
    //MARK: - Properties
    private weak var view: DetailsView!
    private let networkManager: DetailsNetworkManager
    private let router: DefaultDetailsRouter
    private let movieID: Int
    private var movie: DetailModel?
    
    //MARK: - Life Cycle
    init(view: DetailsView,
         networkManager: DetailsNetworkManager,
         router: DefaultDetailsRouter,
         movieID: Int) {
        self.view = view
        self.networkManager = networkManager
        self.router = router
        self.movieID = movieID
    }
    
    //MARK: - Private Methods
    private func convertToModel(item: DetailsData) -> DetailModel {
        let genres = item.genres.map { $0.name }
        let countries = item.countries.map { $0.name }
        let releaseYear: String = .getYear(stringDate: item.releaseDate)
        let model = DetailModel(genres: genres,
                                posterPath: item.posterPath,
                                releaseYear: releaseYear,
                                title: item.title,
                                voteAverage: item.voteAverage,
                                voteCount: item.voteCount,
                                countries: countries,
                                overview: item.overview)
        return model
    }
    
    private func getDetails() {
        let group = DispatchGroup()
        
        // fech details data
        group.enter()
        networkManager.fetchDetails(movieID: movieID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                
                // convert data to model
                self.movie = self.convertToModel(item: data)
                
                // fetch trailer ID for movie
                group.enter()
                self.networkManager.fetchTrailerID(movieID: self.movieID) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let data):
                        let trailer = data.results.first(where: { $0.type.lowercased() == "trailer" })
                        
                        // save trailerID
                        self.movie?.trailerID = trailer?.key
                    case .failure(let error):
                        self.view.didFailWithError(error: error.localizedDescription)
                    }
                    group.leave()
                }
            case .failure(let error):
                self.view.didFailWithError(error: error.localizedDescription)
            }
            group.leave()
        }
        group.notify(queue: .main) {
            
            // send model to show
            self.view.showDetails(movie: self.movie)
        }
    }
}

//MARK: - DetailsPresenterProtocol
extension DetailsViewPresenter: DetailsPresenter {
    func viewDidLoad() {
        getDetails()
    }
    
    func playButtonTapped() {
        guard let trailerID = movie?.trailerID else { return }
        router.showTrailer(trailerID: trailerID)
    }
    
    func posterTapped() {
        guard let movie = movie else { return }
        router.showFullSizePoster(with: movie.posterPath)
    }
}
