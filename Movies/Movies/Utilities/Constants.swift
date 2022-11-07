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

    static let appColor = UIColor(named: "appColor")
    static let placeholder = UIImage(named: "placeholder")
    static let appFont: String = "Futura"
    static let backgroundColorSet: [UIColor] = [
        UIColor(named: "set1")!,
        UIColor(named: "set2")!,
        UIColor(named: "set3")!,
        UIColor(named: "set4")!,
        UIColor(named: "set5")!
    ]

}
