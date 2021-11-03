//
//  StorageManager.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 10/9/21.
//

/*
import Foundation
import CoreData

protocol StorageContext {
	func create(movie: Movie)
	func fetch() -> [Movie]?
	func update(movie: Movie) throws
	func delete(movie: Movie) throws
	func deleteAll() throws
	func saveAll(movies: [Movie]) throws
}

final class StorageManager: StorageContext {
	// MARK: - Private properties
	private let managedObjectContext: NSManagedObjectContext

	// MARK: - Public properties
	init(managedObjectContext: NSManagedObjectContext) {
		self.managedObjectContext = managedObjectContext
	}

	public func create(movie: Movie) {
		do {
			let movieEntitiesResult = try managedObjectContext.fetch(MovieEntity.fetchRequest())

			let movieExist = movieEntitiesResult.first(where: { $0.id == movie.id })

			if movieExist == nil {
				_ = MovieEntity(with: movie, and: managedObjectContext)

				try managedObjectContext.save()
			}

		} catch let error as NSError {
			print("❌ [Storage] [CoreData] [DBManager] [create] An error occurred. \(error.localizedDescription)")
		}
	}

	public func fetch() -> [Movie]? {
		var movies = [Movie]()

		do {
			let movieEntitiesResult = try managedObjectContext.fetch(MovieEntity.fetchRequest())

			for movieEntity in movieEntitiesResult {
				movies.append(Movie(movieEntity: movieEntity))
			}
		} catch let error as NSError {
			print("❌ [Storage] [CoreData] [DBManager] [fetch] An error occurred. \(error.localizedDescription)")
		}

		return movies
	}

	public func delete(movie: Movie) throws {
		do {
			let movieEntitiesResult = try managedObjectContext.fetch(MovieEntity.fetchRequest())

			if let objectToDelete = movieEntitiesResult.first(where: { $0.id == movie.id }) {
				managedObjectContext.delete(objectToDelete)

				try managedObjectContext.save()
			}
		} catch let error as NSError {
			print("❌ [Storage] [CoreData] [DBManager] [delete] An error occurred. \(error.localizedDescription)")
		}
	}

	public func deleteAll() throws {
		do {
			let movieEntitiesResult = try managedObjectContext.fetch(MovieEntity.fetchRequest())

			movieEntitiesResult.forEach { movieEntity in
				managedObjectContext.delete(movieEntity)
			}

			try managedObjectContext.save()
		} catch let error as NSError {
			print("❌ [Storage] [CoreData] [DBManager] [deleteAll] An error occurred. \(error.localizedDescription)")
		}
	}

	public func update(movie: Movie) throws {
		do {
			let movieEntitiesResult = try managedObjectContext.fetch(MovieEntity.fetchRequest())

			if let movieToUpdate = movieEntitiesResult.first(where: { $0.id == movie.id }) {
				movieToUpdate.update(with: movie)
				try managedObjectContext.save()
			}
		} catch let error as NSError {
			print("❌ [Storage] [CoreData] [DBManager] [update] An error occurred. \(error.localizedDescription)")
		}
	}

	public func saveAll(movies: [Movie]) throws {
		do {
			_ = movies.map { movie in
				return MovieEntity(with: movie, and: managedObjectContext)
			}

			try managedObjectContext.save()

		} catch let error as NSError {
			print("❌ [Storage] [CoreData] [DBManager] [create] An error occurred. \(error.localizedDescription)")
		}
	}

	deinit {
		print("🗑 DBManager deinit.")
	}
}
*/
