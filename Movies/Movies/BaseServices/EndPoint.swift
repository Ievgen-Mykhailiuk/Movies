//
//  EndPoint.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

enum EndPoint {
    case popular(page: Int)
    case votes(page: Int)
    case trend(page: Int)
    case poster(path: String)
    case genres
    case search(page: Int, text: String)
    case details(movieID: Int)
    case trailerPath(movieID: Int)
    case trailer(movieID: String)
}

extension EndPoint {
    var domainComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.path = path
        switch self {
        case .popular, .trend, .votes, .genres, .search, .details, .trailerPath:
            components.host = "api.themoviedb.org"
        case .poster:
            components.host = "image.tmdb.org"
        case .trailer:
            components.host = "www.youtube.com"
        }
        return components
    }
   
    var url: URL? {
        var components = domainComponents
        let key = URLQueryItem(name: "api_key", value: Constants.apiKey)
        let language = URLQueryItem(name: "language", value: "en-US")
        switch self {
        case .popular(let page):
            let sortType = URLQueryItem(name: "sort_by", value: "popularity.desc")
            let page = URLQueryItem(name: "page", value: "\(page)")
            components.queryItems = [key, language, sortType, page]
        case .votes(let page):
            let sortType = URLQueryItem(name: "sort_by", value: "vote_count.desc")
            let page = URLQueryItem(name: "page", value: "\(page)")
            components.queryItems = [key, language, sortType, page]
        case .trend(let page):
            let page = URLQueryItem(name: "page", value: "\(page)")
            components.queryItems = [key, language, page]
        case .poster:
            return components.url
        case .genres, .details, .trailerPath:
            components.queryItems = [key, language]
        case .search(let page, let text):
            let query = URLQueryItem(name: "query", value: "\(text)")
            let page = URLQueryItem(name: "page", value: "\(page)")
            components.queryItems = [key, language, query, page]
        case .trailer(let movieID):
            let movieID = URLQueryItem(name: "v", value: "\(movieID)")
            components.queryItems = [movieID]
        }
        return components.url
    }
    
    var path: String {
        switch self {
        case .popular, .votes:
            return "/3/discover/movie"
        case .trend:
            return "/3/trending/movie/week"
        case .poster(let path):
            return "/t/p/original/\(path)"
        case .genres:
            return "/3/genre/movie/list"
        case .search:
            return "/3/search/movie"
        case .details(let movieID):
            return "/3/movie/\(movieID)"
        case .trailerPath(let movieID):
            return "/3/movie/\(movieID)/videos"
        case .trailer:
            return "/watch"
        }
    }
}

//https://api.themoviedb.org/3/movie/{movie_id}?api_key=<<api_key>>&language=en-US


//https://www.youtube.com/watch?v=UgDySaTffdo
