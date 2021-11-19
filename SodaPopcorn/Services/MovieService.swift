//
//  MovieService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Foundation
import Combine
import UIKit

public final class MovieService: MovieNetworkServiceProtocol {
	private let movieNetworkService: MovieNetworkService

	private static let sharedMovieService: MovieService = {
		return MovieService(movieNetworkService: MovieNetworkService())
	}()

	private init(movieNetworkService: MovieNetworkService) {
		self.movieNetworkService = movieNetworkService
	}

	static func shared() -> MovieService {
		return sharedMovieService
	}

	// MARK: Network Service
    // MARK: - Movies
	public func moviesNowPlaying(page: Int) -> AnyPublisher<Movies, NetworkResponse> {
		return movieNetworkService.moviesNowPlaying(page: page)
	}

    public func movieDetails(movieId: String) -> AnyPublisher<Movie, NetworkResponse> {
        return movieNetworkService.movieDetails(movieId: movieId)
    }

    public func movieImages(movieId: String) -> AnyPublisher<MovieImages, NetworkResponse> {
        return movieNetworkService.movieImages(movieId: movieId)
    }

    public func movieExternalIds(movieId: String) -> AnyPublisher<SocialNetworks, NetworkResponse> {
        return movieNetworkService.movieExternalIds(movieId: movieId)
    }

    public func movieVideos(movieId: String) -> AnyPublisher<Videos, NetworkResponse> {
        return movieNetworkService.movieVideos(movieId: movieId)
    }

    public func movieCredits(movieId: String) -> AnyPublisher<Credits, NetworkResponse> {
        return movieNetworkService.movieCredits(movieId: movieId)
    }

    public func movieSimilarMovies(movieId: String, page: Int? = nil) -> AnyPublisher<Movies, NetworkResponse> {
        return movieNetworkService.movieSimilarMovies(movieId: movieId, page: page)
    }

    public func genresList() -> AnyPublisher<Genres, NetworkResponse> {
        return movieNetworkService.genresList()
    }

    public func discover(genre: Int, page: Int) -> AnyPublisher<Movies, NetworkResponse> {
        return movieNetworkService.discover(genre: genre, page: page)
    }

    public func searchMovie(query: String, page: Int) -> AnyPublisher<Movies, NetworkResponse> {
        return movieNetworkService.searchMovie(query: query, page: page)
    }

    // MARK: - Person
    public func personDetails(personId: String) -> AnyPublisher<Person, NetworkResponse> {
        return movieNetworkService.personDetails(personId: personId)
    }

    public func personMovieCredits(personId: String) -> AnyPublisher<[Movie], NetworkResponse> {
        return movieNetworkService.personMovieCredits(personId: personId)
    }

    public func personExternalIds(personId: String) -> AnyPublisher<SocialNetworks, NetworkResponse> {
        return movieNetworkService.personExternalIds(personId: personId)
    }

    public func personImages(personId: String) -> AnyPublisher<PersonImages, NetworkResponse> {
        return movieNetworkService.personImages(personId: personId)
    }
}
