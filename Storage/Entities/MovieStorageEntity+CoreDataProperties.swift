//
//  MovieStorageEntity+CoreDataProperties.swift
//  Storage
//
//  Created by Francisco Cordoba Zimplifica on 3/12/21.
//

import CoreData
import Domain
import Foundation

extension MovieStorageEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieStorageEntity> {
        return NSFetchRequest<MovieStorageEntity>(entityName: "MovieStorageEntity")
    }

    @NSManaged public var rating: Double
    @NSManaged public var voteCount: Int
    @NSManaged public var movieId, title, overview, posterPath, releaseDate: String
    @NSManaged public var adult: Bool
}
