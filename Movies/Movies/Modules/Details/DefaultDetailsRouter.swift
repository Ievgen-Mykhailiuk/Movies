//
//  DefaultDetailsRouter.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit
import YouTubePlayerKit

protocol DetailsRouter {
    func showTrailer(_ trailerID: String)
    func showZoomablePoster(_ poster: UIImage)
}

final class DefaultDetailsRouter: BaseRouter, DetailsRouter {
    func showTrailer(_ trailerID: String) {
        let viewController = YouTubePlayerViewController(source: .video(id: trailerID),
                                                         configuration: .init())
        show(viewController: viewController,
             isModal: false,
             animated: false,
             completion: nil)
    }
    
    func showZoomablePoster(_ poster: UIImage) {
        let viewController = DefaultPosterAssembly().createPosterModule(with: poster)
        show(viewController: viewController,
             isModal: true,
             animated: true,
             completion: nil)
    }
}
