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
typealias MoviesBlock = (Result<MovieResponse, Error>) -> Void
typealias GenresBlock = (Result<Genres, Error>) -> Void
typealias DetailsBlock = (Result<DetailsData, Error>) -> Void
typealias TrailerBlock = (Result<TrailerResponse, Error>) -> Void

struct Constants {
    static let apiKey = "124f09c902f0aae1577860f06cebd903"
    static let offlineMsg = "You are offline. Please enable your Wi-Fi or connect using cellular data"
    static let smallPosterSize = CGSize(width: 230, height: 350)
    static let mediumPosterSize = CGSize(width: 390, height: 520)
}
