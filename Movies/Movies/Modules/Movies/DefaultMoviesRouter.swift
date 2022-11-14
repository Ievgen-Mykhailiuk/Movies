//
//  DefaultMoviesRouter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol MoviesRouter {
    func showDetails(for movie: MovieModel)
}

final class DefaultMoviesRouter: BaseRouter, MoviesRouter {
    func showDetails(for movie: MovieModel) {
        let viewController = DefaultDetailsAssembly().createDetailsModule(for: movie)
        show(viewController: viewController,
             isModal: false,
             animated: true,
             completion: nil)
    }
}
