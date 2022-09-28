//
//  DetailModel.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

struct DetailModel {
    let genres: [String]
    let posterPath: String
    let releaseYear: String
    let title: String
    let voteAverage: Double
    let voteCount: Int
    var trailerID: String?
    let countries: [String]
    let overview: String
}

struct DetailsData: Decodable {
    let genres: [Genre]
    let overview: String
    let posterPath: String
    let countries: [ProductionCountry]
    let releaseDate: String
    let title: String
    let voteAverage: Double
    let voteCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case genres, overview
        case posterPath = "poster_path"
        case countries = "production_countries"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.genres = try container.decode([Genre].self, forKey: .genres)
        self.overview = try container.decode(String.self, forKey: .overview)
        self.countries = try container.decode([ProductionCountry].self, forKey: .countries)
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath) ?? .empty
        self.releaseDate = try container.decode(String.self, forKey: .releaseDate)
        self.title = try container.decode(String.self, forKey: .title)
        self.voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        self.voteCount = try container.decode(Int.self, forKey: .voteCount)
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
