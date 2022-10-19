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
typealias MoviesBlock = (Result<MovieResponse, Error>) -> Void
typealias GenresBlock = (Result<GenresData, Error>) -> Void
typealias DetailsBlock = (Result<DetailsData, Error>) -> Void
typealias TrailerBlock = (Result<TrailerData, Error>) -> Void
typealias DataBaseBlock = (Result<[MovieModel]?, Error>) -> Void

struct Constants {
    static let appBackgroundColor = UIColor(named: "backgroundColor")
    static let appShadowColor = UIColor(named: "shadowColor")
    static let placeholder = UIImage(named: "placeholder")
}
