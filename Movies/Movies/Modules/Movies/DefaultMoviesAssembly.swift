//
//  DefaultMoviesAssembly.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

protocol PostListAssembly {
    func createMoviesModule() -> UIViewController
}

final class DefaultMoviesAssembly: PostListAssembly {
    func createMoviesModule() -> UIViewController {
        let view  = MoviesViewController.instantiateFromStoryboard()
        let apiManager = MoviesAPIService()
        let router = DefaultMoviesRouter(viewController: view)
        let presenter = MoviesViewPresenter(view: view, apiManager: apiManager, router: router)
        view.presenter = presenter
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
}
