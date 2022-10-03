//
//  CoreDataService.swift
//  Movies
//
//  Created by Евгений  on 30/09/2022.
//

import CoreData
import UIKit

final class CoreDataService {
    
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
    
    // MARK: - Core Data Saving support
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
    
    func loadAll(completion: @escaping DataBaseBlock) {
        context.perform {
            do {
                let movieEntities = try MovieEntity.all(context: self.context)
                let movies = movieEntities?.map { MovieModel (genres: $0.genres,
                                                             id: Int($0.id),
                                                             popularity: $0.popularity,
                                                             posterPath: $0.posterPath,
                                                             releaseYear: $0.releaseYear,
                                                             title: $0.title,
                                                             votesAverage: $0.votesAverage,
                                                             votesCount: $0.votesCount,
                                                             overview: $0.overview,
                                                             poster: UIImage(data: $0.poster ?? Data()))}
                completion(.success(movies))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func save(movie: MovieModel, poster: UIImage?, completion: @escaping ErrorBlock) {
        context.perform {
            do {
                let movieEntity = try MovieEntity.find(movieID: movie.id, context: self.context)
                if movieEntity == nil && poster != nil {
                    let newMovie = MovieEntity(context: self.context)
                    newMovie.setValue(movie.genres, forKey: "genres")
                    newMovie.setValue(movie.id, forKey: "id")
                    newMovie.setValue(movie.overview, forKey: "overview")
                    newMovie.setValue(movie.popularity, forKey: "popularity")
                    newMovie.setValue(movie.posterPath, forKey: "posterPath")
                    newMovie.setValue(movie.releaseYear, forKey: "releaseYear")
                    newMovie.setValue(movie.title, forKey: "title")
                    newMovie.setValue(movie.votesAverage, forKey: "votesAverage")
                    newMovie.setValue(movie.votesCount, forKey: "votesCount")
                    if let posterData = poster?.pngData() {
                        newMovie.setValue(posterData, forKey: "poster")
                    }
                }
                self.saveContext()
            } catch {
                completion(error)
            }
        }
    }
}


