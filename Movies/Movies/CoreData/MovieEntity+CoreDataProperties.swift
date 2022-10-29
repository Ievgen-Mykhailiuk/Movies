//
//  MovieEntity+CoreDataProperties.swift
//  Movies
//
//  Created by Евгений  on 11/10/2022.
//
//

import Foundation
import CoreData


extension MovieEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieEntity> {
        return NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
    }

    @NSManaged public var genres:  [String]
    @NSManaged public var id: Int64
    @NSManaged public var overview: String
    @NSManaged public var popularity: String
    @NSManaged public var posterPath: String
    @NSManaged public var releaseYear: String
    @NSManaged public var title: String
    @NSManaged public var votesAverage: String
    @NSManaged public var votesCount: String

}

extension MovieEntity: Identifiable {

}
