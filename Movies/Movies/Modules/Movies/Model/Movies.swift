//
//  Model.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import UIKit

//MARK: - UI Movie Model
struct MovieModel {
    let genres: [String]
    let id: Int
    let popularity: String
    let posterPath: String
    let releaseYear: String
    let title: String
    let votesAverage: String
    let votesCount: String
    let overview: String
    var poster: UIImage? = nil
}

//MARK: - Response Data Model
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
    let posterPath: String
    let releaseDate, title: String
    let votesAverage: Double
    let voteCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case genreIDS = "genre_ids"
        case id, overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title
        case votesAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.genreIDS = try container.decodeIfPresent([Int].self, forKey: .genreIDS) ?? []
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? .zero
        self.overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? .empty
        self.popularity = try container.decodeIfPresent(Double.self, forKey: .popularity) ?? .zero
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath) ?? .empty
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate) ?? .empty
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? .empty
        self.votesAverage = try container.decodeIfPresent(Double.self, forKey: .votesAverage) ?? .zero
        self.voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount) ?? .zero
    }
}

struct Genres: Codable {
    let genres: [GenreModel]
}

struct GenreModel: Codable {
    let id: Int
    let name: String
}
