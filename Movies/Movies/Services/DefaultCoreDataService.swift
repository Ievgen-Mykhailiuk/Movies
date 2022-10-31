//
//  CoreDataService.swift
//  Movies
//
//  Created by Евгений  on 30/09/2022.
//

import CoreData
import Foundation

protocol CoreDataService {
    
    func fetchAll<T: Fetchable>(completion: @escaping (Result<[T], Error>) -> Void)
    func save<T: Fetchable>(_ entities: [T], completion: ErrorBlock?)
    func search<T: Fetchable>(_ searchText: String, completion: @escaping (Result<[T], Error>) -> Void)
    
}

final class DefaultCoreDataService {
    
    //MARK: - Singleton
    static let shared = DefaultCoreDataService()
    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataBase")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    //MARK: - Life Cycle
    private init() {}
    
    // MARK: - Core Data Saving Support
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

//MARK: - CoreDataServiceProtocol
extension DefaultCoreDataService: CoreDataService {
    
    func fetchAll<T: Fetchable>(completion: @escaping (Result<[T], Error>) -> Void) {
        context.perform {
            do {
                let fetchResult: [T] = try T.fetch(in: self.context, predicate: nil)
                completion(.success(fetchResult))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func save<T: Fetchable>(_ entities: [T], completion: ErrorBlock?) {
        context.perform {
            do {
                for entity in entities {
                    let predicate = SearchAttribute.id(entity.identifier).predicate
                    let fetchResult: [T] = try T.fetch(in: self.context, predicate: predicate)
                    fetchResult
                        .filter { item in item !== entity }
                        .forEach { self.context.delete($0) }
                }
                self.saveContext()
            } catch {
                completion?(error)
            }
        }
    }
    
    func search<T: Fetchable>(_ searchText: String, completion: @escaping (Result<[T], Error>) -> Void) {
        context.perform {
            do {
                let predicate = SearchAttribute.title(searchText).predicate
                let fetchResult: [T] = try T.fetch(in: self.context, predicate: predicate)
                completion(.success(fetchResult))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
}
