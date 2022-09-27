//
//  Model.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

struct DetailsData: Decodable {
    let genres: [Genre]
//    let id: Int
    let overview: String
    let posterPath: String
    let productionCountries: [ProductionCountry]
    let releaseDate: String
    let title: String
    let voteAverage: Double
    let voteCount: Int

    private enum CodingKeys: String, CodingKey {
        case genres, overview
        case posterPath = "poster_path"
        case productionCountries = "production_countries"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    struct Genre: Decodable {
        let id: Int
        let name: String
    }
    
    struct ProductionCountry: Decodable {
        let name: String
    }
}

struct TrailerResponse: Decodable {
    let id: Int
    let results: [Trailer]
    struct Trailer: Codable {
        let key: String
        let type: String
    }
}

struct DetailModel {
    let genres: [String]
//    let id: Int
//    let popularity: Double
    let posterPath: String
    let releaseYear: String
    let title: String
    let voteAverage: Double
    let voteCount: Int
//    let trailerPath: String?
    let countries: [String]
    let overview: String
}
