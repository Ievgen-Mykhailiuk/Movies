//
//  CoreDataService.swift
//  Movies
//
//  Created by Евгений  on 30/09/2022.
//

import CoreData
import UIKit

protocol CoreDataService {
    func load(completion: @escaping MoviesBlock)
    func save(movies: [MovieModel], completion: ErrorBlock?)
}

final class DefaultCoreDataService: CoreDataService {
    
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
    
    private lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    //MARK: - Life Cycle
    private init() {}
    
    //MARK: - Private methods
    private func saveEntity(_ entity: MovieEntity, using movie: MovieModel) {
        entity.setValue(movie.genres, forKey: "genres")
        entity.setValue(movie.id, forKey: "id")
        entity.setValue(movie.overview, forKey: "overview")
        entity.setValue(movie.popularity, forKey: "popularity")
        entity.setValue(movie.posterPath, forKey: "posterPath")
        entity.setValue(movie.releaseYear, forKey: "releaseYear")
        entity.setValue(movie.title, forKey: "title")
        entity.setValue(movie.votesAverage, forKey: "votesAverage")
        entity.setValue(movie.votesCount, forKey: "votesCount")
    }
    
    // MARK: - Core Data Saving & Loading support
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
    
    func load(completion: @escaping MoviesBlock) {
        context.perform {
            do {
                let movieEntities = try MovieEntity.all(context: self.context)
                if let movies = movieEntities?.map ({ MovieModel.from(entity: $0)}) {
                    completion(.success(movies))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func save(movies: [MovieModel], completion: ErrorBlock? = nil) {
        context.perform {
            do {
                for movie in movies {
                    if let fetchResult = try MovieEntity.find(movieID: movie.id, context: self.context), fetchResult.count > 0 {
                        assert(fetchResult.count == 1, "Duplicate has found in DB")
                        let movieEntity = fetchResult[0]
                        self.saveEntity(movieEntity, using: movie)
                    } else {
                        let newMovieEntity = MovieEntity(context: self.context)
                        self.saveEntity(newMovieEntity, using: movie)
                    }
                }
                self.saveContext()
            } catch {
                completion?(error)
            }
        }
    }

}


