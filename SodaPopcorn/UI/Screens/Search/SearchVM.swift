//
//  SearchVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/11/21.
//

import Foundation
import Combine

public protocol SearchVMInputs: AnyObject {
    /// Call when a movie is selected.
    func movieSelected(movie: Movie)

    /// Call when view did load.
    func viewDidLoad()

    /// Call when a genre is selected.
    func genreSelected(genre: Genre)

    /// Call when the search text did change.
    func searchTextDidChange(searchQuery: String?)

    /// Call when the search controller change its status.
    func searchControllerDidChange(isActive: Bool)
}

public protocol SearchVMOutputs: AnyObject {
    /// Emits to get the movies.
    func fetchMoviesAction() -> CurrentValueSubject<[Movie]?, Never>

    /// Emits to get the genres.
    func genresAction() -> CurrentValueSubject<[Genre]?, Never>

    /// Emits when loading.
    func loading() -> CurrentValueSubject<Bool, Never>

    /// Emits when a movie is selected.
    func movieSelectedAction() -> PassthroughSubject<Movie, Never>

    /// Emits when all the movied were fetched.
    func finishedFetchingAction() -> CurrentValueSubject<Bool, Never>

    /// Emits when an error occurred.
    func showError() -> PassthroughSubject<String, Never>

    /// Emits when a genre is selected.
    func genreSelectedAction() -> PassthroughSubject<Genre, Never>

    /// Emits when the search controller change its status.
    func searchControllerDidChangeAction() -> PassthroughSubject<Bool, Never>
}

public protocol SearchVMTypes: AnyObject {
    var inputs: SearchVMInputs { get }
    var outputs: SearchVMOutputs { get }
}

public final class SearchVM: ObservableObject, Identifiable, SearchVMInputs, SearchVMOutputs, SearchVMTypes {
    // MARK: Constants
    let movieService: MovieService

    // MARK: Variables
    public var inputs: SearchVMInputs { return self }
    public var outputs: SearchVMOutputs { return self }

    // MARK: Variables
    private var cancellable = Set<AnyCancellable>()

    public init(movieService: MovieService) {
        self.movieService = movieService

        self.movieSelectedProperty
            .sink { [weak self] movie in
                self?.movieSelectedActionProperty.send(movie)
            }.store(in: &cancellable)

        self.genreSelectedProperty
            .sink { [weak self] genre in
                self?.genreSelectedActionProperty.send(genre)
            }.store(in: &cancellable)

        self.searchControllerDidChangeProperty
            .sink { [weak self] isActive in
                self?.searchControllerDidChangeActionProperty.send(isActive)
            }.store(in: &cancellable)

        let genresListEvent = viewDidLoadProperty
            .flatMap({ [weak self] _ -> AnyPublisher<Genres, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                self.loadingProperty.value = true
                return movieService.genresList()
                    .retry(2)
                    .mapError({ [weak self] networkResponse -> NetworkResponse in
                        print("🔴 [SearchVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")
                        self?.loadingProperty.value = false
                        self?.handleNetworkResponseError(networkResponse)
                        return networkResponse
                    })
                    .replaceError(with: Genres())
                     .eraseToAnyPublisher()
            }).share()

        genresListEvent
            .sink(receiveCompletion: { [weak self] completionReceived in
                guard let `self` = self else { return }

                self.loadingProperty.value = false
                switch completionReceived {
                    case .failure(let error):
                        print("🔴 [SearchVM] [init] Received completion error. Error: \(error.localizedDescription)")
                        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] genresList in
                guard let `self` = self else { return }

                self.loadingProperty.value = false
                self.genresActionProperty.value = genresList.genres

            }).store(in: &cancellable)

        let searchMovieEvent = searchTextDidChangeProperty
            .filter({ !($0?.isEmpty ?? true) && ($0?.count ?? 0) >= 4 })
            .throttle(for: 2, scheduler: DispatchQueue.main, latest: true)
            .flatMap({ [weak self] queryText -> AnyPublisher<Movies, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                self.loadingProperty.value = true
                return movieService.searchMovie(query: queryText ?? "", page: 1)
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

        searchMovieEvent
            .sink(receiveCompletion: { [weak self] completionReceived in
                guard let `self` = self else { return }

                self.loadingProperty.value = false
                switch completionReceived {
                    case .failure(let error):
                        print("🔴 [SearchVM] [init] Received completion error. Error: \(error.localizedDescription)")
                        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] movies in
                guard let `self` = self else { return }

                self.loadingProperty.value = false
                self.fetchMoviesActionProperty.value = movies.movies

            }).store(in: &cancellable)
    }

    // MARK: - ⬇️ INPUTS Definition
    private let movieSelectedProperty = PassthroughSubject<Movie, Never>()
    public func movieSelected(movie: Movie) {
        movieSelectedProperty.send(movie)
    }

    private let viewDidLoadProperty = PassthroughSubject<Void, Never>()
    public func viewDidLoad() {
        viewDidLoadProperty.send(())
    }

    private let genreSelectedProperty = PassthroughSubject<Genre, Never>()
    public func genreSelected(genre: Genre) {
        genreSelectedProperty.send(genre)
    }

    private let searchTextDidChangeProperty = PassthroughSubject<String?, Never>()
    public func searchTextDidChange(searchQuery: String?) {
        searchTextDidChangeProperty.send(searchQuery)
    }

    private let searchControllerDidChangeProperty = PassthroughSubject<Bool, Never>()
    public func searchControllerDidChange(isActive: Bool) {
        searchControllerDidChangeProperty.send(isActive)
    }

    // MARK: - ⬆️ OUTPUTS Definition
    private let fetchMoviesActionProperty = CurrentValueSubject<[Movie]?, Never>([])
    public func fetchMoviesAction() -> CurrentValueSubject<[Movie]?, Never> {
        return fetchMoviesActionProperty
    }

    private let genresActionProperty = CurrentValueSubject<[Genre]?, Never>([])
    public func genresAction() -> CurrentValueSubject<[Genre]?, Never> {
        return genresActionProperty
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

    private let genreSelectedActionProperty = PassthroughSubject<Genre, Never>()
    public func genreSelectedAction() -> PassthroughSubject<Genre, Never> {
        return genreSelectedActionProperty
    }

    private let searchControllerDidChangeActionProperty = PassthroughSubject<Bool, Never>()
    public func searchControllerDidChangeAction() -> PassthroughSubject<Bool, Never> {
        return searchControllerDidChangeActionProperty
    }

    // MARK: - ⚙️ Helpers
    private func handleNetworkResponseError(_ networkResponse: NetworkResponse) {
        print("❌ Networkd response error: \(networkResponse.localizedDescription)")
        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network response error"))
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑", "SearchVM deinit.")
    }
}
