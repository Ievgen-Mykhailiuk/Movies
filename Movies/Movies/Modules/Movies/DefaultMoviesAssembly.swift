//
//  DefaultMoviesAssembly.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol MoviesAssembly {
    func createMoviesModule() -> UIViewController
}

final class DefaultMoviesAssembly: MoviesAssembly {
    func createMoviesModule() -> UIViewController {
        let view  = MoviesViewController.instantiateFromStoryboard()
        let dataManager = DefaultMoviesRepository()
        let router = DefaultMoviesRouter(viewController: view)
        let presenter = MoviesViewPresenter(view: view,
                                            dataManager: dataManager,
                                            router: router)
        view.presenter = presenter
        view.title = "Popular Movies"
        let navigationController = UINavigationController(rootViewController: view)
        navigationController.navigationBar.tintColor = Constants.appShadowColor
        navigationController.navigationBar.titleTextAttributes = [
            .font: UIFont(name: Constants.appFont, size: 30) as Any,
            .foregroundColor: Constants.appShadowColor as Any
        ]
        return navigationController
    }
}
