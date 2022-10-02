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
    
    func deleteAll() {
        do {
            let context = persistentContainer.viewContext
            let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
            let objects = try context.fetch(request)
            _ = objects.map {context.delete($0)}
            saveContext()
        } catch {
            print("Deleting error: \(error)")
        }
    }
    
    func getAllMovies(completion: @escaping ([MovieModel]?) -> Void) {
        context.perform {
            let movieEntities = try? MovieEntity.all(context: self.context)
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
            completion(movies)
        }
    }
    
    func saveMovie(movie: MovieModel, poster: UIImage?) {
        context.perform {
            let movieEntity = try? MovieEntity.find(movieID: movie.id, context: self.context)
            if movieEntity == nil {
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
        }
    }
}


