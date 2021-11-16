//
//  SearchVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/11/21.
//

import Foundation
import Combine

public protocol SearchVMInputs: AnyObject {
    /// Call to get the movies.
    func fetchMovies()

    /// Call when a movie is selected.
    func movieSelected(movie: Movie)
}

public protocol SearchVMOutputs: AnyObject {
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

public protocol SearchVMTypes: AnyObject {
    var inputs: SearchVMInputs { get }
    var outputs: SearchVMOutputs { get }
}

public final class SearchVM: ObservableObject, Identifiable, SearchVMInputs, SearchVMOutputs, SearchVMTypes {
    // MARK: Constants
    private let movieService: MovieService

    // MARK: Variables
    public var inputs: SearchVMInputs { return self }
    public var outputs: SearchVMOutputs { return self }

    // MARK: Variables
    private var cancellable = Set<AnyCancellable>()

    public init(movieService: MovieService) {
        self.movieService = movieService

        self.movieSelectedProperty
            .sink { [weak self] movie in
                guard let `self` = self else { return }
                self.movieSelectedActionProperty.send(movie)
            }.store(in: &cancellable)

//        let getNewMoviesEvent = Publishers.Merge(self.fetchNewMoviesProperty, self.pullToRefreshProperty)
//            .flatMap({ [weak self] _ -> AnyPublisher<Movies, Never> in
//                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }
//
//                self.loadingProperty.value = true
//                return movieService.moviesNowPlaying(page: self.page)
//                    .retry(2)
//                    .mapError({ [weak self] networkResponse -> NetworkResponse in
//                        print("🔴 [SearchVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")
//                        self?.loadingProperty.value = false
//                        self?.handleNetworkResponseError(networkResponse)
//                        return networkResponse
//                    })
//                    .replaceError(with: Movies())
//                     .eraseToAnyPublisher()
//            }).share()
//
//        getNewMoviesEvent
//            .sink(receiveCompletion: { [weak self] completionReceived in
//                guard let `self` = self else { return }
//
//                self.loadingProperty.value = false
//                switch completionReceived {
//                    case .failure(let error):
//                        print("🔴 [SearchVM] [init] Received completion error. Error: \(error.localizedDescription)")
//                        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network error message"))
//                    default: break
//                }
//            }, receiveValue: { [weak self] movies in
//                guard let `self` = self else { return }
//
//                self.loadingProperty.value = false
//
//                if movies.numberOfResults != 0 {
//                    print("🔸 MoviesApiResponse [page: \(movies.page ?? 0), numberOfPages: \(movies.numberOfPages ?? 0), numberOfResults: \(movies.numberOfResults ?? 0)]")
//
//                    self.finishedFetchingActionProperty.send(self.page >= movies.numberOfPages ?? 0)
//                    self.fetchMoviesActionProperty.send(movies.movies)
//                }
//            }).store(in: &cancellable)
    }

    // MARK: - ⬇️ INPUTS Definition
    private let fetchMoviesProperty = PassthroughSubject<Void, Never>()
    public func fetchMovies() {
        fetchMoviesProperty.send(())
    }

    private let movieSelectedProperty = PassthroughSubject<Movie, Never>()
    public func movieSelected(movie: Movie) {
        movieSelectedProperty.send(movie)
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
        print("❌ Networkd response error: \(networkResponse.localizedDescription)")
        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network response error"))
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑", "SearchVM deinit.")
    }
}
