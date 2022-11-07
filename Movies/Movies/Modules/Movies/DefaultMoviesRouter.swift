//
//  DefaultMoviesRouter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol MoviesRouter {
    func showDetails(for movieID: Int)
}

final class DefaultMoviesRouter: BaseRouter, MoviesRouter {
    func showDetails(for movieID: Int) {
        let viewController = DefaultDetailsAssembly().createDetailsModule(for: movieID)
        show(viewController: viewController,
             isModal: false,
             animated: true,
             completion: nil)
    }
}
