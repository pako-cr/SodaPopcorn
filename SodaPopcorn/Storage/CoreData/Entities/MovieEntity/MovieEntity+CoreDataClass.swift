//
//  MovieEntity.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/9/21.
//

import CoreData
import Foundation

@objc(MovieEntity)
public class MovieEntity: NSManagedObject, Storable {
	convenience init(with movie: Movie, and context: NSManagedObjectContext) {
		self.init(context: context)
		self.setValue(movie.id, forKey: "id")
		self.setValue(movie.title, forKey: "title")
		self.setValue(movie.posterPath, forKey: "posterPath")
		self.setValue(movie.backdrop, forKey: "backdrop")
		self.setValue(movie.releaseDate, forKey: "releaseDate")
		self.setValue(movie.rating, forKey: "rating")
		self.setValue(movie.overview, forKey: "overview")
		self.setValue(movie.popularity, forKey: "popularity")
		self.setValue(movie.voteCount, forKey: "voteCount")
		self.setValue(movie.posterImageData, forKey: "posterImageData")
	}

	func update(with movie: Movie) {
		self.setValue(movie.title, forKey: "title")
		self.setValue(movie.posterPath, forKey: "posterPath")
		self.setValue(movie.backdrop, forKey: "backdrop")
		self.setValue(movie.releaseDate, forKey: "releaseDate")
		self.setValue(movie.rating, forKey: "rating")
		self.setValue(movie.overview, forKey: "overview")
		self.setValue(movie.popularity, forKey: "popularity")
		self.setValue(movie.voteCount, forKey: "voteCount")
		self.setValue(movie.posterImageData, forKey: "posterImageData")
	}
}
