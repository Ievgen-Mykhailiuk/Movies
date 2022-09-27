//
//  Model.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

struct MovieResponse: Decodable {
    let page: Int
    let results: [MovieData]
    let totalPages, totalResults: Int

    private enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct MovieData: Decodable {
    let genreIDS: [Int]
    let id: Int
    let overview: String
    let popularity: Double
    let posterPath: String?
    let releaseDate, title: String
    let voteAverage: Double
    let voteCount: Int
   
    private enum CodingKeys: String, CodingKey {
        case genreIDS = "genre_ids"
        case id, overview
        case popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    struct Countries: Decodable {
        let name: String
    }
}

struct Genres: Codable {
    let genres: [GenreModel]
}
    struct GenreModel: Codable {
        let id: Int
        let name: String
    }


struct MovieModel {
    let genres: [String]
    let id: Int
    let popularity: Double
    let posterPath: String
    let releaseYear: String
    let title: String
    let voteAverage: Double
    let voteCount: Int
    let overview: String
}




