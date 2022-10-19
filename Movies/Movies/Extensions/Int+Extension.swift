//
//  Int+Extension.swift
//  Movies
//
//  Created by Евгений  on 08/10/2022.
//

import Foundation

extension Int {
    
    var value: Int {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
    
    var stringValue: String {
        return String(self)
    }
    
    mutating func increment() {
       value += 1
    }   
}
