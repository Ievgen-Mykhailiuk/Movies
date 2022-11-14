//
//  DefaultPlayerAssembler.swift
//  Movies
//
//  Created by Евгений  on 10/11/2022.
//

import UIKit

// MARK: - Protocol
protocol PlayerAssembler {
    func createPlayerModule(with trailerID: String) -> UIViewController
}

final class DefaultPlayerAssembler: PlayerAssembler {
    func createPlayerModule(with trailerID: String) -> UIViewController {
        let view = PlayerViewController()
        let router = DefaultPlayerRouter(viewController: view)
        let presenter = DefaultPlayerPresenter(view: view,
                                               router: router,
                                               trailerID: trailerID)
        view.presenter = presenter
        view.modalPresentationStyle = .fullScreen
        return view
    }
}
