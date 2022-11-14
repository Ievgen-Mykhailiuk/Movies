//
//  Trailer.swift
//  Movies
//
//  Created by Евгений  on 08/10/2022.
//

import Foundation

struct TrailerData: Codable {
    
    let results: [Trailer]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.results = try container.decodeIfPresent([Trailer].self, forKey: .results) ?? []
    }
    
    struct Trailer: Codable {
        let key: String
        let type: String
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.key = try container.decodeIfPresent(String.self, forKey: .key) ?? .empty
            self.type = try container.decodeIfPresent(String.self, forKey: .type) ?? .empty
        }
    }
    
}
