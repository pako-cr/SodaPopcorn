//
//  StorageContext.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import CoreData
import Foundation

public enum StorageContextType {
    case create, delete
}

protocol StorageContext {
    func create(movie: Movie)
    func fetch() -> [Movie]?
    func find(movie: Movie) -> Bool
    func delete(movie: Movie) throws
}

extension StorageContext {
    func objectWithObjectId<DBEntity: Storable>(objectId: NSManagedObjectID) -> DBEntity? {
        return nil
    }
}
