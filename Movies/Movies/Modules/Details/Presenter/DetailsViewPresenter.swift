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
}

final class DetailsViewPresenter {
    
    //MARK: - Properties
    private weak var view: DetailsView!
    private let apiManager: DetailsAPIService
    private let router: DefaultDetailsRouter
    private let movieID: Int
    private var movie: DetailModel?
    
    //MARK: - Life Cycle
    init(view: DetailsView,
         apiManager: DetailsAPIService,
         router: DefaultDetailsRouter,
         movieID: Int) {
        self.view = view
        self.apiManager = apiManager
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
                                trailerID: nil,
                                countries: countries,
                                overview: item.overview)
        return model
    }
    
    private func getData() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        apiManager.fetchDetails(movieID: movieID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.movie = self.convertToModel(item: data)
            case .failure(let error):
                self.view.didFailWithError(error: error.localizedDescription)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        apiManager.fetchTrailerID(movieID: movieID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                let trailer = data.results.first(where: { $0.type.lowercased() == "trailer" })
                self.movie?.trailerID = trailer?.key
            case .failure(let error):
                self.view.didFailWithError(error: error.localizedDescription)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.view.showDetails(movie: self.movie)
        }
    }
}

//MARK: - DetailsPresenterProtocol
extension DetailsViewPresenter: DetailsPresenter {
    func playButtonTapped() {
        guard let trailerID = movie?.trailerID else { return }
        router.showTrailer(trailerID: trailerID)
    }
    
    func viewDidLoad() {
        getData()
    }
}
