//
//  FavoritesVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 26/11/21.
//

import Combine
import Domain
import Foundation
import Storage

public protocol FavoritesVMInputs: AnyObject {
    /// Call when a movie is selected.
    func movieSelected(movie: Movie)

    /// Call when view did load.
    func viewDidLoad()

    /// Call to get the new movies.
    func fetchMovies()
}

public protocol FavoritesVMOutputs: AnyObject {
    /// Emits to get the movies.
    func fetchMoviesAction() -> CurrentValueSubject<[Movie]?, Never>

    /// Emits when loading.
    func loading() -> CurrentValueSubject<Bool, Never>

    /// Emits when a movie is selected.
    func movieSelectedAction() -> PassthroughSubject<Movie, Never>

    /// Emits when all the movied were fetched.
    func finishedFetchingAction() -> CurrentValueSubject<Bool, Never>

    /// Emits when an error occurred.
    func showError() -> PassthroughSubject<String, Never>
}

public protocol FavoritesVMTypes: AnyObject {
    var inputs: FavoritesVMInputs { get }
    var outputs: FavoritesVMOutputs { get }
}

public final class FavoritesVM: ObservableObject, Identifiable, FavoritesVMInputs, FavoritesVMOutputs, FavoritesVMTypes {
    // MARK: Constants
    private let movieService: MovieService
    private let storageService: StorageService

    // MARK: Variables
    public var inputs: FavoritesVMInputs { return self }
    public var outputs: FavoritesVMOutputs { return self }

    private var cancellable = Set<AnyCancellable>()
    private var currentFavorites: [Movie]?

    public init(movieService: MovieService, storageService: StorageService) {
        self.movieService = movieService
        self.storageService = storageService

        self.movieSelectedProperty
            .sink { [weak self] movie in
                self?.movieSelectedActionProperty.send(movie)
            }.store(in: &cancellable)

        self.fetchMoviesProperty
            .sink(receiveValue: { _ in
                let movies = storageService.fetch()

                if movies == self.currentFavorites {
                    print("Do not reload")
                } else {
                    print("Do Reload")

                    print("🔸 StorageService Favorites Movies count: \(movies?.count ?? 0)]")
                    self.fetchMoviesActionProperty.send(movies)
                }
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

    private let fetchMoviesProperty = PassthroughSubject<Void, Never>()
    public func fetchMovies() {
        fetchMoviesProperty.send(())
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

    // MARK: - ⚙️ Helpers
    private func handleNetworkResponseError(_ networkResponse: NetworkResponse) {
        print("❌ Network response error: \(networkResponse.localizedDescription)")
        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network response error"))
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑", "FavoritesVM deinit.")
    }
}
