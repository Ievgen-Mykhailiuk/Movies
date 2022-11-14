//
//  DetailModel.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

//MARK: - UI Details Model
struct DetailsModel {
    
    let genres: [String]
    let posterPath: String
    let releaseYear: String
    let title: String
    let voteAverage: Double
    let voteCount: Int
    let countries: [String]
    let overview: String
    var trailerID: String? = nil
    
    static func from(networkModel: DetailsData) -> DetailsModel {
        let genres = networkModel.genres.map { $0.name }
        let countries = networkModel.countries.map { $0.name }
        let releaseYear = Date.getYear(from: networkModel.releaseDate)
        let model = DetailsModel(genres: genres,
                                 posterPath: networkModel.posterPath,
                                 releaseYear: releaseYear,
                                 title: networkModel.title,
                                 voteAverage: networkModel.voteAverage,
                                 voteCount: networkModel.voteCount,
                                 countries: countries,
                                 overview: networkModel.overview)
        return model
    }
    
}

//MARK: - Response Details Data 
struct DetailsData: Codable {
    
    let genres: [GenreModel]
    let overview: String
    let posterPath: String
    let countries: [ProductionCountry]
    let releaseDate: String
    let title: String
    let voteAverage: Double
    let voteCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case genres, overview
        case posterPath = "backdrop_path"
        case countries = "production_countries"
        case releaseDate = "release_date"
        case title
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.genres = try container.decodeIfPresent([GenreModel].self, forKey: .genres) ?? []
        self.overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? .empty
        self.countries = try container.decodeIfPresent([ProductionCountry].self, forKey: .countries) ?? []
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath) ?? .empty
        self.releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate) ?? .empty
        self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? .empty
        self.voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage) ?? .zero
        self.voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount) ?? .zero
    }
    
    struct ProductionCountry: Codable {
        let name: String
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? .empty
        }
    }
    
}
