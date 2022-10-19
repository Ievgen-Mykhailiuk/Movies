//
//  DefaultDetailsAssembly.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol DetailsAssembly {
    func createDetailsModule(movieID: Int) -> UIViewController
}

final class DefaultDetailsAssembly: DetailsAssembly {
    func createDetailsModule(movieID: Int) -> UIViewController {
        let view  = DetailsViewController.instantiateFromStoryboard()
        let router = DefaultDetailsRouter(viewController: view)
        let dataManager = DefaultDetailsRepository()
        let presenter = DetailsViewPresenter(view: view,
                                             dataManager: dataManager,
                                             router: router,
                                             movieID: movieID)
        view.presenter = presenter
        return view
    }
}
