//
//  Constants.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

typealias EmptyBlock = () -> Void
typealias ImageBlock = (UIImage?) -> Void
typealias SortBlock = (UIAlertAction) -> Void
typealias MoviesBlock = (Result<Response, Error>) -> Void
typealias GenresBlock = (Result<Genres, Error>) -> Void

struct Constants {
    static let apiKey = "124f09c902f0aae1577860f06cebd903"
}
