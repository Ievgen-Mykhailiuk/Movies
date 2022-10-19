//
//  NetworkError.swift
//  Movies
//
//  Created by Евгений  on 13/10/2022.
//

import Foundation

enum NetworkError: Error {
    case offline
    
    var localizedDescription: String {
        switch self {
        case .offline:
            return  "You are offline. Please enable your Wi-Fi or connect using cellular data"
        }
    }
}
