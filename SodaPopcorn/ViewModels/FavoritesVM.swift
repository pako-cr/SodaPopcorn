//
//  FavoritesVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 26/11/21.
//

import Combine
import Foundation

public protocol FavoritesVMInputs: AnyObject {
    /// Call when a movie is selected.
    func movieSelected(movie: Movie)

    /// Call to get the new movies.
    func fetchMovies()
}

public protocol FavoritesVMOutputs: AnyObject {
    /// Emits to get the movies.
    func fetchMoviesAction() -> CurrentValueSubject<[Movie]?, Never>

    /// Emits when a movie is included to the favorites list.
    func movieIncludedAction() -> PassthroughSubject<Movie, Never>

    /// Emits when a movie is removed from the favorites list.
    func movieRemovedAction() -> PassthroughSubject<Movie, Never>

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

    public init(movieService: MovieService, storageService: StorageService) {
        self.movieService = movieService
        self.storageService = storageService

        NotificationCenter.default.addObserver(self, selector: #selector(self.managedObjectContextObjectsDidChange(notification:)), name: Notification.Name("storage-service-notification"), object: nil)

        self.movieSelectedProperty
            .sink { [weak self] movie in
                self?.movieSelectedActionProperty.send(movie)
            }.store(in: &cancellable)

        self.fetchMoviesProperty
            .sink(receiveValue: { _ in
                guard let movies = storageService.fetch() else { return }
                print("🔸 StorageService Favorites Movies count: \(movies.count)")
                self.fetchMoviesActionProperty.send(movies)
            }).store(in: &cancellable)
    }

    // MARK: - ⬇️ INPUTS Definition
    private let movieSelectedProperty = PassthroughSubject<Movie, Never>()
    public func movieSelected(movie: Movie) {
        movieSelectedProperty.send(movie)
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

    private let movieIncludedActionProperty = PassthroughSubject<Movie, Never>()
    public func movieIncludedAction() -> PassthroughSubject<Movie, Never> {
        return movieIncludedActionProperty
    }

    private let movieRemovedActionProperty = PassthroughSubject<Movie, Never>()
    public func movieRemovedAction() -> PassthroughSubject<Movie, Never> {
        return movieRemovedActionProperty
    }

    // MARK: - ⚙️ Helpers
    private func handleNetworkResponseError(_ networkResponse: NetworkResponse) {
        print("❌ Network response error: \(networkResponse.localizedDescription)")
        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network response error"))
    }

    @objc
    private func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let movie = notification.object as? Movie,
              let storageContextType = notification.userInfo?.first?.value as? StorageContextType else { return }

        switch storageContextType {
        case .create:
            self.movieIncludedActionProperty.send(movie)

        case .delete:
            self.movieRemovedActionProperty.send(movie)
        }
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑", "FavoritesVM deinit.")
    }
}
