//
//  MoviesVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/9/21.
//

import Foundation
import Combine

public protocol MoviesVMInputs: AnyObject {
	/// Call to get the new movies.
	func fetchMovies()

	/// Call to pull to refresh.
	func pullToRefresh()

	/// Call when a movie is selected.
	func movieSelected(movie: Movie)

    /// Call when the close button is pressed.
    func closeButtonPressed()

    /// Call when the search criteria is changed.
    func setSearchCriteria(searchCriteria: SearchCriteria)
}

public protocol MoviesVMOutputs: AnyObject {
	/// Emits to get the new movies.
	func fetchMoviesAction() -> CurrentValueSubject<[Movie]?, Never>

	/// Emits when loading.
	func loading() -> CurrentValueSubject<Bool, Never>

	/// Emits when a movie is selected.
	func movieSelectedAction() -> PassthroughSubject<Movie, Never>

	/// Emits when all the movied were fetched.
	func finishedFetchingAction() -> CurrentValueSubject<Bool, Never>

	/// Emits when an error occurred.
	func showError() -> PassthroughSubject<String, Never>

    /// Emits when the close button is pressed.
    func closeButtonAction() -> PassthroughSubject<Void, Never>

    /// Emits when the search criteria is changed.
    func setSearchCriteriaAction() -> PassthroughSubject<SearchCriteria, Never>
}

public protocol MoviesVMTypes: AnyObject {
	var inputs: MoviesVMInputs { get }
	var outputs: MoviesVMOutputs { get }
}

public final class MoviesVM: ObservableObject, Identifiable, MoviesVMInputs, MoviesVMOutputs, MoviesVMTypes {
	// MARK: Constants
	private let movieService: MovieService
    let presentedViewController: Bool

	// MARK: Variables
	public var inputs: MoviesVMInputs { return self }
	public var outputs: MoviesVMOutputs { return self }

	// MARK: Variables
	private var cancellable = Set<AnyCancellable>()
    private var searchCriteria = SearchCriteria.nowPlaying
	private var page = 0

    public init(movieService: MovieService, searchCriteria: SearchCriteria, presentedViewController: Bool) {
		self.movieService = movieService
        self.searchCriteria = searchCriteria
        self.presentedViewController = presentedViewController

		self.movieSelectedProperty
			.sink { [weak self] movie in
				guard let `self` = self else { return }
				self.movieSelectedActionProperty.send(movie)
			}.store(in: &cancellable)

        self.closeButtonPressedProperty
            .sink { [weak self] in
                self?.closeButtonActionProperty.send(())
            }.store(in: &cancellable)

        self.setSearchCriteriaProperty
            .sink { [weak self] searchCriteria in
                self?.setSearchCriteriaActionProperty.send(searchCriteria)
            }.store(in: &cancellable)

        let getMoviesEvent = Publishers.Merge(self.fetchMoviesProperty, self.pullToRefreshProperty)
            .filter({ _ in
                switch self.searchCriteria {
                case .nowPlaying: return true
                default: return false
                }
            })
			.flatMap({ [weak self] _ -> AnyPublisher<Movies, Never> in
				guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                self.loadingProperty.value = true
                return movieService.moviesNowPlaying(page: self.page)
                    .retry(2)
					.mapError({ [weak self] networkResponse -> NetworkResponse in
						print("🔴 [MoviesVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")
                        self?.loadingProperty.value = false
						self?.handleNetworkResponseError(networkResponse)
						return networkResponse
					})
					.replaceError(with: Movies())
				 	.eraseToAnyPublisher()
            }).share()

        let searchByGenreEvent = Publishers.Merge(self.fetchMoviesProperty, self.pullToRefreshProperty)
            .filter({ _ in
                switch self.searchCriteria {
                case .discover:
                    return true
                default:
                    return false
                }
            })
            .flatMap({ [weak self] _ -> AnyPublisher<Movies, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                self.loadingProperty.value = true
                var genreId = 0

                switch self.searchCriteria {
                case .discover(let genre): genreId = genre
                default: break
                }

                return movieService.discover(genre: genreId, page: self.page)
                    .retry(2)
                    .mapError({ [weak self] networkResponse -> NetworkResponse in
                        print("🔴 [SearchVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")
                        self?.loadingProperty.value = false
                        self?.handleNetworkResponseError(networkResponse)
                        return networkResponse
                    })
                    .replaceError(with: Movies())
                     .eraseToAnyPublisher()
            }).share()

        Publishers.Merge(
            searchByGenreEvent,
            getMoviesEvent)
            .sink(receiveCompletion: { [weak self] completionReceived in
                guard let `self` = self else { return }

				self.loadingProperty.value = false
				switch completionReceived {
					case .failure(let error):
						print("🔴 [MoviesVM] [init] Received completion error. Error: \(error.localizedDescription)")
						self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network error message"))
					default: break
				}
			}, receiveValue: { [weak self] movies in
				guard let `self` = self else { return }

				self.loadingProperty.value = false

				if movies.numberOfResults != 0 {
					print("🔸 MoviesApiResponse [page: \(movies.page ?? 0), numberOfPages: \(movies.numberOfPages ?? 0), numberOfResults: \(movies.numberOfResults ?? 0)]")

					self.finishedFetchingActionProperty.send(self.page >= movies.numberOfPages ?? 0)
					self.fetchMoviesActionProperty.send(movies.movies)
				}
			}).store(in: &cancellable)
	}

	// MARK: - ⬇️ INPUTS Definition
	private let fetchMoviesProperty = PassthroughSubject<Void, Never>()
	public func fetchMovies() {
        self.page += 1
		fetchMoviesProperty.send(())
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

    private let closeButtonPressedProperty = PassthroughSubject<Void, Never>()
    public func closeButtonPressed() {
        closeButtonPressedProperty.send(())
    }

    private let setSearchCriteriaProperty = PassthroughSubject<SearchCriteria, Never>()
    public func setSearchCriteria(searchCriteria: SearchCriteria) {
        setSearchCriteriaProperty.send(searchCriteria)
    }

	// MARK: - ⬆️ OUTPUTS Definition
	private let fetchMoviesActionProperty = CurrentValueSubject<[Movie]?, Never>([])
	public func fetchMoviesAction() -> CurrentValueSubject<[Movie]?, Never> {
		return fetchMoviesActionProperty
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

    private let closeButtonActionProperty = PassthroughSubject<Void, Never>()
    public func closeButtonAction() -> PassthroughSubject<Void, Never> {
        return closeButtonActionProperty
    }

    private let setSearchCriteriaActionProperty = PassthroughSubject<SearchCriteria, Never>()
    public func setSearchCriteriaAction() -> PassthroughSubject<SearchCriteria, Never> {
        return setSearchCriteriaActionProperty
    }

	// MARK: - ⚙️ Helpers
    private func handleNetworkResponseError(_ networkResponse: NetworkResponse) {
        print("❌ Networkd response error: \(networkResponse.localizedDescription)")
        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network response error"))
    }

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑", "MoviesVM deinit.")
	}
}
