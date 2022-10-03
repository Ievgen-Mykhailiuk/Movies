//
//  String+Extension.swift
//  Movies
//
//  Created by Евгений  on 26/09/2022.
//

import Foundation

extension String {
    
    static let empty = ""
    
    static func getYear(stringDate: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.date(from: stringDate)  ?? Date()
        let year = String(Calendar.current.component(.year, from: date))
        return year
    }
}
