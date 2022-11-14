//
//  EndPoint.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation
import Alamofire

protocol EndPointType {
    var httpMethod: HTTPMethod { get }
    var baseUrl: String { get }
    var path: String { get }
    var headers: HTTPHeaders? { get }
    var body: [String: Any]? { get }
    var parameters: [String: Any]? { get }
    var encoding: ParameterEncoding { get }
}

enum EndPoint {
    case movies(sortType: SortType, page: Int)
    case poster(size: PosterSize, path: String)
    case genres
    case search(page: Int, text: String)
    case details(movieID: Int)
    case trailerID(movieID: Int)
}

extension EndPoint: EndPointType {
    var urlString: String {
        return baseUrl + apiVersion + path
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .movies, .poster, .genres, .search, .details, .trailerID:
            return .get
        }
    }
    
    var baseUrl: String {
        switch self {
        case .movies, .genres, .search, .details, .trailerID:
            return "https://api.themoviedb.org/"
        case .poster:
            return "https://image.tmdb.org/"
        }
    }
    
    var path: String {
        switch self {
        case .movies(let sortType, _):
            return "/movie/\(sortType.path)"
        case .poster(let size, let path):
            return "/t/p/\(size.rawValue)/\(path)"
        case .genres:
            return "/genre/movie/list"
        case .search:
            return "/search/movie"
        case .details(let movieID):
            return "/movie/\(movieID)"
        case .trailerID(let movieID):
            return "/movie/\(movieID)/videos"
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .movies, .poster, .genres, .search, .details, .trailerID:
            return nil
        }
    }
    
    var body: [String : Any]? {
        switch self {
        case .movies, .poster, .genres, .search, .details, .trailerID:
            return nil
        }
    }
    
    var parameters: [String : Any]? {
        var parameters: [String : Any] = ["api_key" : apiKey, "language" : apiLanguage]
        switch self {
        case .movies(_, let page):
            parameters["page"] = page.stringValue
            return parameters
        case .poster:
            return nil
        case .genres, .details, .trailerID:
            return parameters
        case .search(let page, let text):
            parameters["query"] = text
            parameters["page"] = page.stringValue
            return parameters
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .movies, .poster, .genres, .search, .details, .trailerID:
            return URLEncoding.default
        }
    }
}
    
private extension EndPoint {
    var apiKey: String {
        return  "124f09c902f0aae1577860f06cebd903"
    }
    var apiVersion: String {
        return "3"
    }
    var apiLanguage: String {
        return "en-US"
    }
}
