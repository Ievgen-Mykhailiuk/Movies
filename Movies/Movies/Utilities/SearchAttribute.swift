//
//  SearchAttribute.swift
//  Movies
//
//  Created by Евгений  on 27/10/2022.
//

import Foundation

enum SearchAttribute {
    case id(Int)
    case title(String)
    
    var predicate: NSPredicate {
        switch self {
        case .id(let id):
            return  .init(format: "id == %d", id)
        case .title(let text):
            return  .init(format: "title CONTAINS[cd] %@", text)
        }
    }
}
