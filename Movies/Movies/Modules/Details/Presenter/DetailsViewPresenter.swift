//
//  DetailsViewPresenter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol DetailsPresenter {
    func viewDidLoad()
    func playTrailer()
    func showPoster(_ poster: UIImage)
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
            case .success(let movie):
                self?.movie = movie
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
            case .success(let trailerID):
                self?.movie?.trailerID = trailerID
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
        router.showTrailer(trailerID)
    }
    
    func showPoster(_ poster: UIImage) {
        router.showZoomablePoster(poster)
    }
}
