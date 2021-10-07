//
//  NewMoviesListVM.swift
//  StarWarsWorld
//
//  Created by Francisco Cordoba on 3/9/21.
//

import Foundation
import Combine

public protocol NewMoviesListVMInputs: AnyObject {
	/// Call to get the new movies.
	func fetchNewMovies()

	/// Call to pull to refresh.
	func pullToRefresh()

	/// Call when a movie is selected.
	func movieSelected(movie: Movie)
}

public protocol NewMoviesListVMOutputs: AnyObject {
	/// Emits to get the new movies.
	func fetchNewMoviesAction() -> CurrentValueSubject<[Movie]?, Never>

	/// Emits to get return the image.
	func fetchPosterImageSignal() -> PassthroughSubject<(Int, Data), Never>

	/// Emits when loading.
	func loading() -> CurrentValueSubject<Bool, Never>

	/// Emits when a movie is selected.
	func movieSelectedAction() -> PassthroughSubject<Movie, Never>
}

public protocol NewMoviesListVMTypes: AnyObject {
	var inputs: NewMoviesListVMInputs { get }
	var outputs: NewMoviesListVMOutputs { get }
}

public final class NewMoviesListVM: ObservableObject, Identifiable, NewMoviesListVMInputs, NewMoviesListVMOutputs, NewMoviesListVMTypes {
	// MARK: Constants
	private let movieService: MovieService
	private let imageService: PosterImageService

	// MARK: Variables
	public var inputs: NewMoviesListVMInputs { return self }
	public var outputs: NewMoviesListVMOutputs { return self }

	// MARK: Variables
	private var cancellable = Set<AnyCancellable>()
	private var page = 0

	init(movieService: MovieService, imageService: PosterImageService) {
		self.movieService = movieService
		self.imageService = imageService

		self.movieSelectedProperty
			.sink { [weak self] movie in
				guard let `self` = self else { return }
				self.movieSelectedActionProperty.send(movie)
			}.store(in: &cancellable)

		Publishers.Merge(self.fetchNewMoviesProperty, self.pullToRefreshProperty)
			.flatMap({ [weak self] _ -> AnyPublisher<MovieApiResponse?, Error> in
				guard let `self` = self else { return Empty(completeImmediately: false).eraseToAnyPublisher() }
				return self.getNewMovies()
			})
			.sink(receiveCompletion: { [weak self] completion in
				guard let `self` = self else { return }

				self.loadingProperty.value = false
				switch completion {
					case .failure(let error):
						print("🔴 [NewMoviesListVM] [init] Received completion error. Error: \(error.localizedDescription)")
					default: break
				}
			}, receiveValue: { [weak self] movieApiResponse in
				guard let `self` = self else { return }

				self.loadingProperty.value = false
				if let movieApiResponse = movieApiResponse {
					print("🔸 MoviesApiResponse [page: \(movieApiResponse.page), numberOfPages: \(movieApiResponse.numberOfPages), numberOfResults: \(movieApiResponse.numberOfResults)]")
					self.fetchNewMoviesActionProperty.value = movieApiResponse.movies
				}
			}).store(in: &cancellable)
	}

	// MARK: - ⬇️ INPUTS Definition
	private let fetchNewMoviesProperty = PassthroughSubject<Void, Never>()
	public func fetchNewMovies() {
		fetchNewMoviesProperty.send(())
	}

	private let pullToRefreshProperty = PassthroughSubject<Void, Never>()
	public func pullToRefresh() {
		self.page = 0
		pullToRefreshProperty.send(())
	}

	private let movieSelectedProperty = PassthroughSubject<Movie, Never>()
	public func movieSelected(movie: Movie) {
		movieSelectedProperty.send(movie)
	}

	// MARK: - ⬆️ OUTPUTS Definition
	private let fetchNewMoviesActionProperty = CurrentValueSubject<[Movie]?, Never>([])
	public func fetchNewMoviesAction() -> CurrentValueSubject<[Movie]?, Never> {
		return fetchNewMoviesActionProperty
	}

	private let fetchPosterImageSignalProperty = PassthroughSubject<(Int, Data), Never>()
	public func fetchPosterImageSignal() -> PassthroughSubject<(Int, Data), Never> {
		return fetchPosterImageSignalProperty
	}

	private let loadingProperty = CurrentValueSubject<Bool, Never>(false)
	public func loading() -> CurrentValueSubject<Bool, Never> {
		return loadingProperty
	}

	private let movieSelectedActionProperty = PassthroughSubject<Movie, Never>()
	public func movieSelectedAction() -> PassthroughSubject<Movie, Never> {
		return movieSelectedActionProperty
	}

	// MARK: - ⚙️ Helpers
	private func getNewMovies() -> AnyPublisher<MovieApiResponse?, Error> {
		self.page += 1
		self.loadingProperty.value = true
		return movieService.getNewMovies(page: page)
	}

	public func getPosterImage(movie: Movie, posterPath: String, completion: @escaping (_ imageData: Data?, _ error: String?) -> Void) {
		imageService.getPosterImage(posterPath: posterPath, posterSize: PosterSize.w154) { data, error in
			completion(data, error)

//			guard let `self` = self, let data = data, !data.isEmpty else { return }
//			self.fetchPosterImageSignalProperty.send((movie.id, data))
		}
	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑", "NewMoviesListVM deinit.")
	}
}
