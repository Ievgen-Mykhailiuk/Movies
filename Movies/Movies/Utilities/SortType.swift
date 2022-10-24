//
//  SortType.swift
//  Movies
//
//  Created by Евгений  on 13/10/2022.
//

import Foundation

enum SortType: String {
    case nowPlaying
    case popular
    case topRated
    case upcoming
    
    var path: String {
        switch self {
        case .nowPlaying:
            return "now_playing"
        case .popular:
            return "popular"
        case .topRated:
             return "top_rated"
        case .upcoming:
            return "upcoming"
        }
    }
}
