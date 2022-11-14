//
//  MovieEntity+CoreDataClass.swift
//  Movies
//
//  Created by Евгений  on 11/10/2022.
//
//

import Foundation

final class MovieEntity: BaseEntity  {
    
    override var identifier: Int {
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
