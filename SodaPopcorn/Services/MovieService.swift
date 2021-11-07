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

public final class MovieService: MovieNetworkServiceProtocol {
	private let movieNetworkService: MovieNetworkService

	private static let sharedMovieService: MovieService = {
		let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
		return MovieService(movieNetworkService: MovieNetworkService())
	}()

	private init(movieNetworkService: MovieNetworkService) {
		self.movieNetworkService = movieNetworkService
	}

	static func shared() -> MovieService {
		return sharedMovieService
	}

	// MARK: - Network Service
	public func getNewMovies(page: Int) -> AnyPublisher<Movies, NetworkResponse> {
		return movieNetworkService.getNewMovies(page: page)
	}

    public func movieDetails(movieId: String) -> AnyPublisher<Movie, NetworkResponse> {
        return movieNetworkService.movieDetails(movieId: movieId)
    }

    public func getImages(movieId: String) -> AnyPublisher<MovieImages, NetworkResponse> {
        return movieNetworkService.getImages(movieId: movieId)
    }

    public func socialNetworks(movieId: String) -> AnyPublisher<SocialNetworks, NetworkResponse> {
        return movieNetworkService.socialNetworks(movieId: movieId)
    }

	// MARK: - Storage Context
//	func create(movie: Movie) {
//		storageManager.create(movie: movie)
//	}
//
//	func fetch() -> [Movie]? {
//		return storageManager.fetch()
//	}
//
//	func update(movie: Movie) throws {
//		try storageManager.update(movie: movie)
//	}
//
//	func delete(movie: Movie) throws {
//		try storageManager.delete(movie: movie)
//	}
//
//	func deleteAll() throws {
//		try storageManager.deleteAll()
//	}
//
//	func saveAll(movies: [Movie]) throws {
//		try storageManager.saveAll(movies: movies)
//	}
}
