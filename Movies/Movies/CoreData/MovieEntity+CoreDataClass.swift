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
    
    class func find(movieID: Int, context: NSManagedObjectContext) throws -> [MovieEntity]? {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", movieID)
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
