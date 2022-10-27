//
//  MovieEntity+CoreDataClass.swift
//  Movies
//
//  Created by Евгений  on 11/10/2022.
//
//

import Foundation
import CoreData

public class MovieEntity: NSManagedObject {
        
    class func find(in attribute: SearchAttribute, context: NSManagedObjectContext) throws -> [MovieEntity]? {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = attribute.predicate
        do {
            let fetchResult = try context.fetch(request)
            return fetchResult
        } catch {
            throw error
        }
    }

    class func all(context: NSManagedObjectContext) throws -> [MovieEntity]? {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        do {
            let fetchResult = try context.fetch(request)
            return fetchResult
        } catch {
            throw error
        }
    }

}
