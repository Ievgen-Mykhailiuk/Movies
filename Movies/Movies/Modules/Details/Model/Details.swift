//
//  DetailModel.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

//MARK: - UI Details Model
struct DetailModel {
    let genres: [String]
    let posterPath: String
    let releaseYear: String
    let title: String
    let voteAverage: Double
    let voteCount: Int
    var trailerID: String? = nil
    let countries: [String]
    let overview: String
}

//MARK: - Response Data Model
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
        self.genres = try container.decodeIfPresent([Genre].self, forKey: .genres) ?? []
        self.overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? .empty
        self.countries = try container.decodeIfPresent([ProductionCountry].self, forKey: .countries) ?? []
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath) ?? .empty
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate) ?? .empty
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? .empty
        self.voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage) ?? .zero
        self.voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount) ?? .zero
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
    
    struct Trailer: Decodable {
        let key: String
        let type: String
    }
}
