//
//  MovieStorageEntity+CoreDataProperties.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import CoreData
import Foundation

extension MovieStorageEntity {
    convenience init(with movie: Movie, and context: NSManagedObjectContext) {
        self.init(context: context)
        self.setValue(movie.movieTitle, forKey: "movieTitle")
        self.setValue(movie.overview, forKey: "overview")
        self.setValue(movie.rating, forKey: "rating")
        self.setValue(movie.posterPath, forKey: "posterPath")
        self.setValue(movie.releaseDate, forKey: "releaseDate")
        self.setValue(movie.voteCount, forKey: "voteCount")
        self.setValue(movie.adult, forKey: "adult")
        self.setValue(movie.backdropPath, forKey: "backdropPath")
        self.setValue(movie.tagline, forKey: "tagline")
        self.setValue(movie.homepage, forKey: "homepage")
        self.setValue(movie.id, forKey: "id")
    }
}

extension Movie {
    public init(movieStorageEntity: MovieStorageEntity) {
        self.init(
            id: movieStorageEntity.id ?? UUID().uuidString,
            movieTitle: movieStorageEntity.movieTitle,
            overview: movieStorageEntity.overview,
            rating: movieStorageEntity.rating,
            posterPath: movieStorageEntity.posterPath,
            backdropPath: movieStorageEntity.backdropPath,
            releaseDate: movieStorageEntity.releaseDate,
            homepage: movieStorageEntity.homepage,
            voteCount: Int(movieStorageEntity.voteCount),
            tagline: movieStorageEntity.tagline,
            adult: movieStorageEntity.adult)
    }
}
