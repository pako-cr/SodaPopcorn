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

	/// Emits when loading.
	func loading() -> CurrentValueSubject<Bool, Never>

	/// Emits when a movie is selected.
	func movieSelectedAction() -> PassthroughSubject<Movie, Never>

	/// Emits when all the movied were fetched.
	func finishedFetchingAction() -> CurrentValueSubject<Bool, Never>

	/// Emits when an error occurred.
	func showError() -> PassthroughSubject<String, Never>
}

public protocol NewMoviesListVMTypes: AnyObject {
	var inputs: NewMoviesListVMInputs { get }
	var outputs: NewMoviesListVMOutputs { get }
}

public final class NewMoviesListVM: ObservableObject, Identifiable, NewMoviesListVMInputs, NewMoviesListVMOutputs, NewMoviesListVMTypes {
	// MARK: Constants
	private let movieService: MovieService

	// MARK: Variables
	public var inputs: NewMoviesListVMInputs { return self }
	public var outputs: NewMoviesListVMOutputs { return self }

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
			.flatMap({ [weak self] _ -> AnyPublisher<MoviesApiResponse, Never> in
				guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                self.loadingProperty.value = true
                return movieService.getNewMovies(page: self.page)
                    .retry(2)
					.mapError({ [weak self] networkResponse -> NetworkResponse in
						print("🔴 [NewMoviesListVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")
                        self?.loadingProperty.value = false
						self?.handleNetworkResponseError(networkResponse)
						return networkResponse
					})
					.replaceError(with: MoviesApiResponse(page: 0, numberOfResults: 0, numberOfPages: 0, movies: []))
				 	.eraseToAnyPublisher()
            }).share()

		getNewMoviesEvent
			.sink(receiveCompletion: { [weak self] completionReceived in
				guard let `self` = self else { return }

				self.loadingProperty.value = false
				switch completionReceived {
					case .failure(let error):
						print("🔴 [NewMoviesListVM] [init] Received completion error. Error: \(error.localizedDescription)")
						self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
					default: break
				}
			}, receiveValue: { [weak self] moviesApiResponse in
				guard let `self` = self else { return }

				self.loadingProperty.value = false

				if moviesApiResponse.numberOfResults != 0 {
					print("🔸 MoviesApiResponse [page: \(moviesApiResponse.page), numberOfPages: \(moviesApiResponse.numberOfPages), numberOfResults: \(moviesApiResponse.numberOfResults)]")

					self.finishedFetchingActionProperty.send(self.page >= moviesApiResponse.numberOfPages)
					self.fetchNewMoviesActionProperty.send(moviesApiResponse.movies)
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
		print("🗑", "NewMoviesListVM deinit.")
	}
}
