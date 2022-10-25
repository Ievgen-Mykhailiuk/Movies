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
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
}
