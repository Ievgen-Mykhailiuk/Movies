//
//  DefaultMoviesRouter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol MoviesRouter {
    func showDetails(movieID: Int)
}

final class DefaultMoviesRouter: BaseRouter, MoviesRouter {
    func showDetails(movieID: Int) {
        let viewController = DefaultDetailsAssembly().createDetailsModule(movieID: movieID)
        show(viewController: viewController,
             isModal: false,
             animated: true,
             completion: nil)
    }
}
