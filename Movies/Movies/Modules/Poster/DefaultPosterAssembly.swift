//
//  DefaultPosterAssembly.swift
//  Movies
//
//  Created by Евгений  on 28/09/2022.
//

import UIKit

protocol PosterAssembly {
    func createPosterModule(with poster: UIImage) -> UIViewController
}

final class DefaultPosterAssembly: PosterAssembly {    
    func createPosterModule(with poster: UIImage) -> UIViewController {
        let view = PosterViewController(poster: poster)
        let router = DefaultPosterRouter(viewController: view) 
        let presenter = PosterViewPresenter(view: view, router: router)
        view.presenter = presenter
        view.modalPresentationStyle = .fullScreen
        return view
    }
}
