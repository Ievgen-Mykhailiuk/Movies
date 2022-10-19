//
//  DetailsViewPresenter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol DetailsPresenter {
    func viewDidLoad()
    func playTrailer()
    func showPoster()
}

final class DetailsViewPresenter {
    
    //MARK: - Properties
    private weak var view: DetailsView!
    private let dataManager: DefaultDetailsRepository
    private let router: DefaultDetailsRouter
    private let movieID: Int
    private var movie: DetailsModel?
    
    //MARK: - Life Cycle
    init(view: DetailsView,
         dataManager: DefaultDetailsRepository,
         router: DefaultDetailsRouter,
         movieID: Int) {
        self.view = view
        self.dataManager = dataManager
        self.router = router
        self.movieID = movieID
    }
    
    //MARK: - Private Methods
    private func getDetails() {
        dataManager.fetchDetails(movieID: movieID) { [weak self] result in
            switch result {
            case .success(let data):
                self?.movie = DetailsModel.from(networkModel: data)
                self?.getTrailerID {
                    self?.view.showDetails(movie: self?.movie)
                }
            case .failure(let error):
                self?.view.showError(with: error.localizedDescription)
            }
        }
    }
    
    private func getTrailerID(completion: EmptyBlock? = nil) {
        dataManager.fetchTrailerID(movieID: movieID) { [weak self] result in
            switch result {
            case .success(let data):
                let trailer = data.results.first(where: { $0.type.lowercased() == "trailer" })
                self?.movie?.trailerID = trailer?.key
            case .failure(let error):
                self?.view.showError(with: error.localizedDescription)
            }
            completion?()
        }
    }

}

//MARK: - DetailsPresenterProtocol
extension DetailsViewPresenter: DetailsPresenter {
    func viewDidLoad() {
        getDetails()
    }
    
    func playTrailer() {
        guard let trailerID = movie?.trailerID else { return }
        router.showTrailer(trailerID: trailerID)
    }
    
    func showPoster() {
        guard let movie = movie else { return }
        if !movie.posterPath.isEmpty {
            router.showFullSizePoster(with: movie.posterPath)
        }
    }
}
