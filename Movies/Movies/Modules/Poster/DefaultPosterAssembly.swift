//
//  DefaultPosterAssembly.swift
//  Movies
//
//  Created by Евгений  on 28/09/2022.
//

import UIKit

protocol PosterAssembly {
    func createPosterModule(with path: String) -> UIViewController
}

final class DefaultPosterAssembly: PosterAssembly {    
    func createPosterModule(with path: String) -> UIViewController {
        let view = PosterViewController()
        let router = DefaultPosterRouter(viewController: view) 
        let presenter = PosterViewPresenter(view: view, router: router, path: path)
        view.presenter = presenter
        view.modalPresentationStyle = .fullScreen
        return view
    }
}
