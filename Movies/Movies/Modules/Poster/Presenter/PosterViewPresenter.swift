//
//  PosterViewPresenter.swift
//  Movies
//
//  Created by Евгений  on 28/09/2022.
//

import Foundation

protocol PosterPresenter {
    func getPoster()
    func posterSwiped()
}

final class PosterViewPresenter {
    
    //MARK: - Properties
    private weak var view: PosterView!
    private let router: DefaultPosterRouter
    private let path: String
    
    //MARK: - Life Cycle
    init(view: PosterView, router: DefaultPosterRouter, path: String) {
        self.view = view
        self.router = router
        self.path = path
    }
}

//MARK: - PosterPresenterProtocol
extension PosterViewPresenter: PosterPresenter {
    func getPoster() {
        self.view.showPoster(with: path)
    }
    
    func posterSwiped() {
        router.close()
    }
}
