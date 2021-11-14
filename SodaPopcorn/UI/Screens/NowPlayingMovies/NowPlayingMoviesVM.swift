//
//  NowPlayingMoviesVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/9/21.
//

import Foundation
import Combine

public protocol NowPlayingMoviesVMInputs: AnyObject {
	/// Call to get the new movies.
	func fetchNewMovies()

	/// Call to pull to refresh.
	func pullToRefresh()

	/// Call when a movie is selected.
	func movieSelected(movie: Movie)
}

public protocol NowPlayingMoviesVMOutputs: AnyObject {
	/// Emits to get the new movies.
	func fetchNewMoviesAction() -> CurrentValueSubject<[Movie]?, Never>

	/// Emits when loading.
	func loading() -> CurrentValueSubject<Bool, Never>

	/// Emits when a movie is selected.
	func movieSelectedAction() -> PassthroughSubject<Movie, Never>

	/// Emits when all the movied were fetched.
	func finishedFetchingAction() -> CurrentValueSubject<Bool, Never>

	/// Emits when an error occurred.
	func showError() -> PassthroughSubject<String, Never>
}

public protocol NowPlayingMoviesVMTypes: AnyObject {
	var inputs: NowPlayingMoviesVMInputs { get }
	var outputs: NowPlayingMoviesVMOutputs { get }
}

public final class NowPlayingMoviesVM: ObservableObject, Identifiable, NowPlayingMoviesVMInputs, NowPlayingMoviesVMOutputs, NowPlayingMoviesVMTypes {
	// MARK: Constants
	private let movieService: MovieService

	// MARK: Variables
	public var inputs: NowPlayingMoviesVMInputs { return self }
	public var outputs: NowPlayingMoviesVMOutputs { return self }

	// MARK: Variables
	private var cancellable = Set<AnyCancellable>()
	private var page = 0

	public init(movieService: MovieService) {
		self.movieService = movieService

		self.movieSelectedProperty
			.sink { [weak self] movie in
				guard let `self` = self else { return }
				self.movieSelectedActionProperty.send(movie)
			}.store(in: &cancellable)

		let getNewMoviesEvent = Publishers.Merge(self.fetchNewMoviesProperty, self.pullToRefreshProperty)
			.flatMap({ [weak self] _ -> AnyPublisher<Movies, Never> in
				guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                self.loadingProperty.value = true
                return movieService.moviesNowPlaying(page: self.page)
                    .retry(2)
					.mapError({ [weak self] networkResponse -> NetworkResponse in
						print("🔴 [NowPlayingMoviesVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")
                        self?.loadingProperty.value = false
						self?.handleNetworkResponseError(networkResponse)
						return networkResponse
					})
					.replaceError(with: Movies())
				 	.eraseToAnyPublisher()
            }).share()

		getNewMoviesEvent
			.sink(receiveCompletion: { [weak self] completionReceived in
				guard let `self` = self else { return }

				self.loadingProperty.value = false
				switch completionReceived {
					case .failure(let error):
						print("🔴 [NowPlayingMoviesVM] [init] Received completion error. Error: \(error.localizedDescription)")
						self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
					default: break
				}
			}, receiveValue: { [weak self] movies in
				guard let `self` = self else { return }

				self.loadingProperty.value = false

				if movies.numberOfResults != 0 {
					print("🔸 MoviesApiResponse [page: \(movies.page ?? 0), numberOfPages: \(movies.numberOfPages ?? 0), numberOfResults: \(movies.numberOfResults ?? 0)]")

					self.finishedFetchingActionProperty.send(self.page >= movies.numberOfPages ?? 0)
					self.fetchNewMoviesActionProperty.send(movies.movies)
				}
			}).store(in: &cancellable)
	}

	// MARK: - ⬇️ INPUTS Definition
	private let fetchNewMoviesProperty = PassthroughSubject<Void, Never>()
	public func fetchNewMovies() {
        self.page += 1
		fetchNewMoviesProperty.send(())
	}

	private let pullToRefreshProperty = PassthroughSubject<Void, Never>()
	public func pullToRefresh() {
		self.page = 1
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

	private let loadingProperty = CurrentValueSubject<Bool, Never>(false)
	public func loading() -> CurrentValueSubject<Bool, Never> {
		return loadingProperty
	}

	private let movieSelectedActionProperty = PassthroughSubject<Movie, Never>()
	public func movieSelectedAction() -> PassthroughSubject<Movie, Never> {
		return movieSelectedActionProperty
	}

	private let finishedFetchingActionProperty = CurrentValueSubject<Bool, Never>(false)
	public func finishedFetchingAction() -> CurrentValueSubject<Bool, Never> {
		return finishedFetchingActionProperty
	}

	private let showErrorProperty = PassthroughSubject<String, Never>()
	public func showError() -> PassthroughSubject<String, Never> {
		return showErrorProperty
	}

	// MARK: - ⚙️ Helpers
	private func handleNetworkResponseError(_ networkResponse: NetworkResponse) {
		var localizedErrorString: String

		switch networkResponse {

			case .authenticationError: localizedErrorString = "network_response_error_authentication_error"
			case .badRequest: localizedErrorString = "network_response_error_bad_request"
			case .outdated: localizedErrorString = "network_response_error_outdated"
			case .failed: localizedErrorString = "network_response_error_failed"
			case .noData: localizedErrorString = "network_response_error_no_data"
			case .unableToDecode: localizedErrorString = "network_response_error_unable_to_decode"
			default: localizedErrorString = "network_response_error_failed"
		}

		self.showErrorProperty.send(NSLocalizedString(localizedErrorString, comment: "Network response error"))
	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑", "NowPlayingMoviesVM deinit.")
	}
}
