//
//  MovieEntity+CoreDataClass.swift
//  Movies
//
//  Created by Евгений  on 11/10/2022.
//
//

import Foundation
import CoreData

protocol EntityType {
    static func all<T: NSManagedObject>(in context: NSManagedObjectContext) throws -> [T]?
    static func find<T: NSManagedObject>(in context: NSManagedObjectContext,
                                         with predicate: NSPredicate?) throws -> [T]?
}

extension EntityType {
    static func all<T: NSManagedObject>(in context: NSManagedObjectContext) throws -> [T]? {
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.entity = T.entity()
        do {
            let fetchResult = try context.fetch(fetchRequest)
            return fetchResult
        } catch {
            throw error
        }
    }
    
    static func find<T: NSManagedObject>(in context: NSManagedObjectContext,
                                         with predicate: NSPredicate?) throws -> [T]? {
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

public class MovieEntity: NSManagedObject {

}
