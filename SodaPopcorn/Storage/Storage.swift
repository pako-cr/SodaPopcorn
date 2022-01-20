//
//  Storage.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import CoreData
import Foundation

public final class Storage: StorageContext {
    // MARK: - Private properties
    private let managedObjectContext: NSManagedObjectContext

    public init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    public func create(movie: Movie) {
        do {
            let result = try managedObjectContext.fetch(MovieStorageEntity.fetchRequest())

            let movieExist = result.first(where: { $0.id == movie.id })

            if movieExist == nil {
                _ = MovieStorageEntity(with: movie, and: managedObjectContext)

                try managedObjectContext.save()

                NotificationCenter.default.post(Notification(name: Notification.Name("storage-service-notification"), object: movie, userInfo: ["storageContextType": StorageContextType.create]))
            }

        } catch let error as NSError {
            print("❌ [SodaPopcorn] [Storage] [create] An error occurred. \(error.localizedDescription)")
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
            print("❌ [SodaPopcorn] [Storage] [fetch] An error occurred. \(error.localizedDescription)")
        }

        return movies
    }

    public func find(movie: Movie) -> Bool {
        do {
            let result = try managedObjectContext.fetch(MovieStorageEntity.fetchRequest())

            return result.contains(where: { $0.id == movie.id })

        } catch let error as NSError {
            print("❌ [SodaPopcorn] [Storage] [find] An error occurred. \(error.localizedDescription)")
        }

        return false
    }

    public func delete(movie: Movie) throws {
        do {
            let result = try managedObjectContext.fetch(MovieStorageEntity.fetchRequest())

            if let objectToDelete = result.first(where: { $0.id == movie.id }) {
                managedObjectContext.delete(objectToDelete)

                try managedObjectContext.save()
                NotificationCenter.default.post(Notification(name: Notification.Name("storage-service-notification"), object: movie, userInfo: ["storageContextType": StorageContextType.delete]))
            }

        } catch let error as NSError {
            print("❌ [SodaPopcorn] [Storage] [delete] An error occurred. \(error.localizedDescription)")
        }
    }

    deinit {
        print("🗑 StorageService deinit.")
    }
}
