//
//  StorageService.swift
//  Storage
//
//  Created by Francisco Cordoba on 3/12/21.
//

import CoreData
import Domain
import Foundation

public final class StorageService: StorageContext {
    // MARK: - Private properties
    private let managedObjectContext: NSManagedObjectContext

    // MARK: - Public properties
    public init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    public func create(movie: Movie) {
        do {
            let result = try managedObjectContext.fetch(MovieStorageEntity.fetchRequest())

            let movieExist = result.first(where: { $0.movieId == movie.movieId })

            if movieExist == nil {
                _ = MovieStorageEntity(with: movie, and: managedObjectContext)

                try managedObjectContext.save()
            }

        } catch let error as NSError {
            print("❌ [Storage] [CoreData] [DBManager] [create] An error occurred. \(error.localizedDescription)")
        }
    }

    public func fetch() -> [Movie]? {
        var movies = [Movie]()

        do {
            let result = try managedObjectContext.fetch(MovieStorageEntity.fetchRequest())

            for movieStorageEntity in result {
                movies.append(Movie(movieStorageEntity: movieStorageEntity))
            }

        } catch let error as NSError {
            print("❌ [Storage] [CoreData] [DBManager] [fetch] An error occurred. \(error.localizedDescription)")
        }

        return movies
    }

    public func find(movie: Movie) -> Bool {
        do {
            let result = try managedObjectContext.fetch(MovieStorageEntity.fetchRequest())

            return result.contains(where: { $0.movieId == movie.movieId })

        } catch let error as NSError {
            print("❌ [Storage] [CoreData] [DBManager] [find] An error occurred. \(error.localizedDescription)")
        }

        return false
    }

    public func delete(movie: Movie) throws {
        do {
            let result = try managedObjectContext.fetch(MovieStorageEntity.fetchRequest())

            if let objectToDelete = result.first(where: { $0.movieId == movie.movieId }) {
                managedObjectContext.delete(objectToDelete)

                try managedObjectContext.save()
            }

        } catch let error as NSError {
            print("❌ [Storage] [CoreData] [DBManager] [delete] An error occurred. \(error.localizedDescription)")
        }
    }

    public func deleteAll() throws {
        do {
            let result = try managedObjectContext.fetch(MovieStorageEntity.fetchRequest())


            result.forEach { movieEntity in
                managedObjectContext.delete(movieEntity)
            }

            try managedObjectContext.save()

        } catch let error as NSError {
            print("❌ [Storage] [CoreData] [DBManager] [deleteAll] An error occurred. \(error.localizedDescription)")
        }
    }

    public func update(movie: Movie) throws {
        do {
            let result = try managedObjectContext.fetch(MovieStorageEntity.fetchRequest())

            if let movieToUpdate = result.first(where: { $0.movieId == movie.movieId }) {
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
                return MovieStorageEntity(with: movie, and: managedObjectContext)
            }

            try managedObjectContext.save()

        } catch let error as NSError {
            print("❌ [Storage] [CoreData] [DBManager] [create] An error occurred. \(error.localizedDescription)")
        }
    }

    deinit {
        print("🗑 StorageService deinit.")
    }
}
