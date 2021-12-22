//
//  StorageContext.swift
//  Storage
//
//  Created by Francisco Cordoba on 3/12/21.
//

import CoreData
import Domain
import Foundation

protocol StorageContext {
    func create(movie: Movie)
    func fetch() -> [Movie]?
    func update(movie: Movie) throws
    func delete(movie: Movie) throws
    func deleteAll() throws
    func saveAll(movies: [Movie]) throws
}

extension StorageContext {
    func objectWithObjectId<DBEntity: Storable>(objectId: NSManagedObjectID) -> DBEntity? {
        return nil
    }
}
