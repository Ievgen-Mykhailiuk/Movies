//
//  Constants.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

typealias ErrorBlock = (Error) -> Void
typealias EmptyBlock = () -> Void
typealias ImageBlock = (UIImage?) -> Void
typealias ActionBlock = (UIAlertAction) -> Void
typealias MoviesBlock = (Result<[MovieModel], Error>) -> Void
typealias GenresBlock = (Result<[GenreModel], Error>) -> Void
typealias DetailsBlock = (Result<DetailsModel, Error>) -> Void
typealias TrailerBlock = (Result<String?, Error>) -> Void

struct Constants {
    static let appBackgroundColor = UIColor(named: "backgroundColor")
    static let appShadowColor = UIColor(named: "shadowColor")
    static let placeholder = UIImage(named: "placeholder")
    static let appFont: String = "Futura"
}
