//
//  StorageService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 12/1/22.
//

import CoreData.NSManagedObjectContext
import Foundation
import UIKit.UIApplication

public final class StorageService: StorageContext {
	// MARK: - Private properties
	private let storage: Storage

	public static func shared() -> StorageService {
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			return StorageService(managedObjectContext: appDelegate.persistentContainer.viewContext)
		}

		return StorageService(managedObjectContext: NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
	}

	private init(managedObjectContext: NSManagedObjectContext) {
		self.storage = Storage(managedObjectContext: managedObjectContext)
	}

	public func create(movie: Movie) {
		self.storage.create(movie: movie)
	}

	public func fetch() -> [Movie]? {
		self.storage.fetch()
	}

	public func find(movie: Movie) -> Bool {
		self.storage.find(movie: movie)
	}

	public func delete(movie: Movie) throws {
		try self.storage.delete(movie: movie)
	}

	deinit {
		print("🗑 StorageService deinit.")
	}
}
