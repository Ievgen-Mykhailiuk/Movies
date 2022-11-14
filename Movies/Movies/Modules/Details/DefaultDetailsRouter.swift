//
//  DefaultDetailsRouter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol DetailsRouter {
    func showTrailer(_ trailerID: String)
    func showZoomablePoster(_ poster: UIImage)
}

final class DefaultDetailsRouter: BaseRouter, DetailsRouter {
    func showTrailer(_ trailerID: String) {
        let viewController = DefaultPlayerAssembler().createPlayerModule(with: trailerID)
        show(viewController: viewController, isModal: true, animated: true)
    }
    
    func showZoomablePoster(_ poster: UIImage) {
        let viewController = DefaultPosterAssembly().createPosterModule(with: poster)
        show(viewController: viewController, isModal: true, animated: true)
    }
}
