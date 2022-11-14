//
//  PosterViewPresenter.swift
//  Movies
//
//  Created by Евгений  on 28/09/2022.
//

import Foundation

protocol PosterPresenter {
    func close()
}

final class PosterViewPresenter {
    
    //MARK: - Properties
    private weak var view: PosterView!
    private let router: DefaultPosterRouter
    
    //MARK: - Life Cycle
    init(view: PosterView, router: DefaultPosterRouter) {
        self.view = view
        self.router = router
    }
}

//MARK: - PosterPresenterProtocol
extension PosterViewPresenter: PosterPresenter {
    func close() {
        router.close()
    }
}
