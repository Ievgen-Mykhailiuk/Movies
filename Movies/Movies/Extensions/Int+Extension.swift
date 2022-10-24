//
//  Int+Extension.swift
//  Movies
//
//  Created by Евгений  on 08/10/2022.
//

import Foundation

extension Int {

    var stringValue: String {
        return String(self)
    }
    
    mutating func increment() {
       self += 1
    }   
}
