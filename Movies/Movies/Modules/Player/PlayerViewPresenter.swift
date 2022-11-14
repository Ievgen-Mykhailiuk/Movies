//
//  File.swift
//  Movies
//
//  Created by Евгений  on 10/11/2022.
//

import Foundation

// MARK: - Protocol
protocol PlayerPresenter {
    func viewDidLoad()
    func close()
}

final class DefaultPlayerPresenter {
    // MARK: - Properties
    private weak var view: PlayerView?
    private let router: PlayerRouter
    private var trailerID: String
    
    // MARK: - Life Cycle Methods
    init(view: PlayerView,
         router: PlayerRouter,
         trailerID: String) {
        self.view = view
        self.router = router
        self.trailerID = trailerID
    }
}

//MARK: - PlayerPresenterProtocol
extension DefaultPlayerPresenter: PlayerPresenter {

    func viewDidLoad() {
        view?.playTrailer(with: trailerID)
    }
    
    func close() {
        router.close()
    }
    
}
