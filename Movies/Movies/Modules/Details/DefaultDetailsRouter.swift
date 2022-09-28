//
//  DefaultDetailsRouter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

protocol DetailsRouter {
    func showTrailer(trailerID: String)
}


final class DefaultDetailsRouter: BaseRouter, DetailsRouter {
    func showTrailer(trailerID: String) {
        let viewController = DefaultDetailsAssembly().createTrailerModule(trailerID: trailerID)
        show(viewController: viewController,
             isModal: true,
             animated: true,
             completion: nil)
    }
}
