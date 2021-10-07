//
//  MovieEntity+CoreDataProperties.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/9/21.
//

import Foundation
import CoreData

extension MovieEntity {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<MovieEntity> {
		return NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
	}

	@NSManaged public var id: String
	@NSManaged public var posterPath: String
	@NSManaged public var title: String
	@NSManaged public var rating: Double
	@NSManaged public var overview: String
	@NSManaged public var posterImageData: Data?
}
