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
        let networkManager = MoviesNetworkManager()
        let dataBaseManager = CoreDataService()
        let router = DefaultMoviesRouter(viewController: view)
        let presenter = MoviesViewPresenter(view: view,
                                            networkManager: networkManager,
                                            dataBaseManager: dataBaseManager,
                                            router: router)
        view.presenter = presenter
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
}
