//
//  MovieService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Foundation
import Combine
import CoreData
import UIKit

public final class MovieService: MovieNetworkServiceProtocol, StorageContext {
	private let movieNetworkService: MovieNetworkService
	private let storageManager: StorageManager

	private static let sharedMovieService: MovieService = {
		let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
		return MovieService(movieNetworkService: MovieNetworkService(), storageManager: StorageManager(managedObjectContext: managedObjectContext!))
	}()

	private init(movieNetworkService: MovieNetworkService, storageManager: StorageManager) {
		self.movieNetworkService = movieNetworkService
		self.storageManager = storageManager
	}

	static func shared() -> MovieService {
		return sharedMovieService
	}

	// MARK: - Network Service
	public func getNewMovies(page: Int) -> AnyPublisher<[Movie]?, Error> {
		return movieNetworkService.getNewMovies(page: page)
	}

	// MARK: - Storage Context
	func create(movie: Movie) {
		storageManager.create(movie: movie)
	}

	func fetch() -> [Movie]? {
		return storageManager.fetch()
	}

	func update(movie: Movie) throws {
		try storageManager.update(movie: movie)
	}

	func delete(movie: Movie) throws {
		try storageManager.delete(movie: movie)
	}

	func deleteAll() throws {
		try storageManager.deleteAll()
	}

	func saveAll(movies: [Movie]) throws {
		try storageManager.saveAll(movies: movies)
	}
}
