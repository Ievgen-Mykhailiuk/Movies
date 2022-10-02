//
//  MovieEntity+CoreDataClass.swift
//  Movies
//
//  Created by Евгений  on 02/10/2022.
//
//

import Foundation
import CoreData

final public class MovieEntity: NSManagedObject {
    
    class func find(movieID: Int, context: NSManagedObjectContext) throws -> MovieEntity? {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", movieID)
        
        do {
            let fetchResult = try context.fetch(request)
            if fetchResult.count > 0 {
                assert(fetchResult.count == 1, "Duplicate has found in DB")
                return fetchResult[0]
            } else {
                return nil
            }
        } catch {
            throw error
        }
    }
    
    class func all(context: NSManagedObjectContext) throws -> [MovieEntity] {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        
        do {
            let fetchResult = try context.fetch(request)
            return fetchResult
        } catch {
            throw error
        }
    }
}

