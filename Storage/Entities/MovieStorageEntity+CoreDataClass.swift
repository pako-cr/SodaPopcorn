//
//  MovieStorageEntity.swift
//  Storage
//
//  Created by Francisco Cordoba on 3/12/21.
//

import CoreData
import Domain
import Foundation

@objc(MovieStorageEntity)
public class MovieStorageEntity: NSManagedObject, Storable {
    convenience init(with movie: Movie, and context: NSManagedObjectContext) {
        self.init(context: context)
        self.setValue(movie.movieId, forKey: "movieId")
        self.setValue(movie.title, forKey: "title")
        self.setValue(movie.overview, forKey: "overview")
        self.setValue(movie.rating, forKey: "rating")
        self.setValue(movie.posterPath, forKey: "posterPath")
        self.setValue(movie.releaseDate, forKey: "releaseDate")
        self.setValue(movie.voteCount, forKey: "voteCount")
        self.setValue(movie.adult, forKey: "adult")
    }

    func update(with movie: Movie) {
        self.setValue(movie.movieId, forKey: "movieId")
        self.setValue(movie.title, forKey: "title")
        self.setValue(movie.overview, forKey: "overview")
        self.setValue(movie.posterPath, forKey: "posterPath")
        self.setValue(movie.releaseDate, forKey: "releaseDate")
        self.setValue(movie.voteCount, forKey: "voteCount")
        self.setValue(movie.adult, forKey: "adult")
    }
}
