//
//  MovieEntity+CoreDataClass.swift
//  Movies
//
//  Created by Евгений  on 11/10/2022.
//
//

import Foundation
import CoreData

protocol EntityType: NSManagedObject {
    
    var identifier: Int { get }
    static func fetch<T: NSManagedObject>(in context: NSManagedObjectContext,
                                          predicate: NSPredicate?) throws -> [T]
    
}

extension EntityType {

    static func fetch<T: NSManagedObject>(in context: NSManagedObjectContext,
                                          predicate: NSPredicate?) throws -> [T] {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.entity = T.entity()
        fetchRequest.predicate = predicate
        do {
            let fetchResult = try context.fetch(fetchRequest)
            return fetchResult
        } catch {
            throw error
        }
    }
    
}

public class MovieEntity: NSManagedObject, EntityType {
    
    var identifier: Int {
        return self.id.intValue
    }
    
    class func from(model: MovieModel) -> MovieEntity {
        let entity = MovieEntity(context: DefaultCoreDataService.shared.context)
        entity.setValue(model.genres, forKey: "genres")
        entity.setValue(model.id, forKey: "id")
        entity.setValue(model.overview, forKey: "overview")
        entity.setValue(model.popularity, forKey: "popularity")
        entity.setValue(model.posterPath, forKey: "posterPath")
        entity.setValue(model.releaseYear, forKey: "releaseYear")
        entity.setValue(model.title, forKey: "title")
        entity.setValue(model.votesAverage, forKey: "votesAverage")
        entity.setValue(model.votesCount, forKey: "votesCount")
        return entity
    }
    
}
