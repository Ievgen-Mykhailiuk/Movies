//
//  BaseEntity.swift
//  Movies
//
//  Created by Евгений  on 31/10/2022.
//

import Foundation
import CoreData

protocol Fetchable: NSManagedObject {
    
    var identifier: Int { get }
    static func fetch<T: NSManagedObject>(in context: NSManagedObjectContext,
                                          predicate: NSPredicate?) throws -> [T]
    
}

class BaseEntity: NSManagedObject, Fetchable {
   
    var identifier: Int {
        return .zero
    }
   
    class func fetch<T: NSManagedObject>(in context: NSManagedObjectContext,
                                         predicate: NSPredicate?) throws -> [T] {
        let fetchRequest = T.fetchRequest() as! NSFetchRequest<T>
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
