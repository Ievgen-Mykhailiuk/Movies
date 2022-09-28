//
//  DefaultPosterRouter.swift
//  Movies
//
//  Created by Евгений  on 28/09/2022.
//

import Foundation

protocol PosterRouter {
    func close()
}

final class DefaultPosterRouter: BaseRouter, PosterRouter {
    func close() {
         close(animated: true, completion: nil)
    }
}
