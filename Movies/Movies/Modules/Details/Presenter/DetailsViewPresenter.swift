//
//  DetailsViewPresenter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol DetailsPresenter: AnyObject {
    func viewDidLoad()
}

final class DetailsViewPresenter {
    
    //MARK: - Properties
    private weak var view: DetailsView!
    private let apiManager: DetailsAPIService
    private let router: DefaultDetailsRouter
    private var movie: DetailModel? {
        didSet {
            view.showDetails(movie: movie)
        }
    }
    private var movieID: Int
    private var trailerPath: String?
    
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
    
    private func convertToModel(item: DetailsData) -> DetailModel {
        let genres = item.genres.map { $0.name }
        let countries = item.productionCountries.map { $0.name }
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
   
    private func getDetails(movieID: Int) {
        apiManager.fetchDetails(movieID: movieID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.movie = self.convertToModel(item: data)
            case .failure(let error):
                self.view.didFailWithError(error: error.localizedDescription)
            }
        }
    }
    
    private func getTrailerPath(movieID: Int) {
        apiManager.fetchTrailerPath(movieID: movieID) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                let trailer = data.results.first(where: { $0.type.lowercased() == "trailer" })
                self.trailerPath = trailer?.key
            case .failure(let error):
                self.view.didFailWithError(error: error.localizedDescription)
            }
        }
    }
    
}

extension DetailsViewPresenter: DetailsPresenter {
    func viewDidLoad() {
        getDetails(movieID: movieID)
        getTrailerPath(movieID: movieID)
    }
}
