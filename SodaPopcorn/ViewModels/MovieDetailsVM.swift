//
//  MovieDetailsVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 7/10/21.
//

import Combine
import CoreData
import Foundation
import UIKit

public protocol MovieDetailsVMInputs: AnyObject {
	/// Call when the view did load.
	func viewDidLoad()

	/// Call when the close button is pressed.
	func closeButtonPressed()

    /// Call when an backdrop image is selected from the movie details.
    func backdropImageSelected(imageURL: String)

    /// Call when the gallery button is pressed.
    func galleryButtonPressed()

    /// Call when the credits button is pressed.
    func creditsButtonPressed()

    /// Call when a cast member is selected.
    func castMemberSelected(cast: Cast)

    /// Call when the movie's overview is pressed.
    func overviewTextPressed()

    /// Call when a movie is selected from the movie details.
    func movieSelected(movie: Movie)

    /// Call when a favorite button is pressed.
    func favoriteButtonPressed(movie: Movie)
}

public protocol MovieDetailsVMOutputs: AnyObject {
	/// Emits to close the screen.
	func closeButtonAction() -> PassthroughSubject<Void, Never>

	/// Emits to get return the movie information.
	func movieInfoAction() -> PassthroughSubject<Movie, Never>

	/// Emits when loading.
	func loading() -> CurrentValueSubject<Bool, Never>

    /// Emits when an error occurred.
    func showError() -> PassthroughSubject<String, Never>

    /// Emits when the credits information is fetched.
    func creditsAction() -> CurrentValueSubject<Credits?, Never>

    /// Emits when the social networks are fetched.
    func socialNetworksAction() -> CurrentValueSubject<SocialNetworks?, Never>

    /// Emits when the gallery button is pressed.
    func galleryButtonAction() -> PassthroughSubject<Void, Never>

    /// Emits when a cast member is selected.
    func castMemberAction() -> PassthroughSubject<Person, Never>

    /// Emits when the credits button is pressed.
    func creditsButtonAction() -> PassthroughSubject<(Movie, Credits), Never>

    /// Emits when the movie's overview is pressed.
    func overviewTextAction() -> PassthroughSubject<String, Never>

    /// Emits to return the similar movies.
    func similarMoviesAction() -> CurrentValueSubject<[Movie]?, Never>

    /// Emits when a movie is selected.
    func movieSelectedAction() -> PassthroughSubject<Movie, Never>

    /// Emits when a favorite button is pressed.
    func favoriteChanged() -> CurrentValueSubject<Bool, Never>
}

public protocol MovieDetailsVMTypes: AnyObject {
	var inputs: MovieDetailsVMInputs { get }
	var outputs: MovieDetailsVMOutputs { get }
}

public final class MovieDetailsVM: ObservableObject, Identifiable, MovieDetailsVMInputs, MovieDetailsVMOutputs, MovieDetailsVMTypes {
	// MARK: Constants
    private let movieService: MovieService
    private let movie: Movie
    private let storageService: StorageService

	// MARK: Variables
	public var inputs: MovieDetailsVMInputs { return self }
	public var outputs: MovieDetailsVMOutputs { return self }

	private var cancellable = Set<AnyCancellable>()

    init(movieService: MovieService, storageService: StorageService, movie: Movie) {
        self.movieService = movieService
        self.storageService = storageService
		self.movie = movie

		viewDidLoadProperty.sink { [weak self] _ in
			guard let `self` = self else { return }
            self.movieInfoActionProperty.send(self.movie)
            self.favoriteChangedProperty.send(self.handleIsFavorite(movie: self.movie))
		}.store(in: &cancellable)

		closeButtonPressedProperty.sink { [weak self] _ in
			self?.closeButtonActionProperty.send(())
		}.store(in: &cancellable)

        galleryButtonPressedProperty.sink { [weak self] _ in
            guard let `self` = self else { return }
            self.galleryButtonActionProperty.send(())
        }.store(in: &cancellable)

        castMemberSelectedProperty.sink { [weak self] cast in
            let person = Person(name: cast.name, id: cast.id)
            self?.castMemberActionProperty.send(person)
        }.store(in: &cancellable)

        creditsButtonPressedProperty.sink { [weak self] _ in
            if let credits = self?.creditsActionProperty.value, let movie = self?.movie {
                self?.creditsButtonActionProperty.send((movie, credits))
            }
        }.store(in: &cancellable)

        overviewTextPressedProperty.sink { [weak self] (overview) in
            guard let `self` = self, let overview = self.movie.overview else { return }
            self.overviewTextActionProperty.send(overview)
        }.store(in: &cancellable)

        movieSelectedProperty.sink { [weak self] (movie) in
            self?.movieSelectedActionProperty.send(movie)
        }.store(in: &cancellable)

        favoriteButtonPressedProperty.sink { [weak self] movie in
            guard let `self` = self else { return }
            self.favoriteChangedProperty.send(self.handleFavoriteChange(movie: movie))
        }.store(in: &cancellable)

        let movieDetailsEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<Movie, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                self.loadingProperty.value = true

                return movieService.movieDetails(movieId: self.movie.id)
                    .mapError({ [weak self] networkResponse -> NetworkResponse in
                        print("🔴 [MovieDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")
                        self?.loadingProperty.value = false
                        self?.handleNetworkResponseError(networkResponse)
                        return networkResponse
                    })
                    .replaceError(with: self.movie)
                    .eraseToAnyPublisher()
            }.share()

        movieDetailsEvent
            .sink(receiveCompletion: { [weak self] completionReceived in
                guard let `self` = self else { return }

                self.loadingProperty.value = false

                switch completionReceived {
                    case .failure(let error):
                        print("🔴 [MovieDetailsVM] [init] Received completion error. Error: \(error.localizedDescription)")
                        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] movieDetails in
                guard let `self` = self else { return }

                self.loadingProperty.value = false

                self.movieInfoActionProperty.send(movieDetails)
            }).store(in: &cancellable)

        let movieExternalIdsEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<SocialNetworks, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                return movieService.movieExternalIds(movieId: self.movie.id)
                    .mapError({ [weak self] networkResponse -> NetworkResponse in
                        print("🔴 [MovieDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")

                        self?.handleNetworkResponseError(networkResponse)
                        return networkResponse
                    })
                    .replaceError(with: SocialNetworks())
                    .eraseToAnyPublisher()
            }.share()

        movieExternalIdsEvent
            .sink(receiveCompletion: { [weak self] completionReceived in
                guard let `self` = self else { return }

                switch completionReceived {
                    case .failure(let error):
                        print("🔴 [MovieDetailsVM] [init] Received completion error. Error: \(error.localizedDescription)")
                        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] socialNetworks in
                guard let `self` = self else { return }
                self.socialNetworksActionProperty.value = socialNetworks

            }).store(in: &cancellable)

        let creditsEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<Credits, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                return movieService.movieCredits(movieId: self.movie.id)
                    .mapError({ [weak self] networkResponse -> NetworkResponse in
                        print("🔴 [MovieDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")

                        self?.handleNetworkResponseError(networkResponse)
                        return networkResponse
                    })
                    .replaceError(with: Credits())
                    .eraseToAnyPublisher()
            }.share()

        creditsEvent
            .sink(receiveCompletion: { [weak self] completionReceived in
                guard let `self` = self else { return }

                switch completionReceived {
                    case .failure(let error):
                        print("🔴 [MovieDetailsVM] [init] Received completion error. Error: \(error.localizedDescription)")
                        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] credits in
                guard let `self` = self else { return }
                self.creditsActionProperty.value = credits

            }).store(in: &cancellable)

        let similarMoviesEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<Movies, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                return movieService.movieSimilarMovies(movieId: self.movie.id)
                    .mapError({ [weak self] networkResponse -> NetworkResponse in
                        print("🔴 [MovieDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")
                        self?.loadingProperty.value = false
                        self?.handleNetworkResponseError(networkResponse)
                        return networkResponse
                    })
                    .replaceError(with: Movies())
                    .eraseToAnyPublisher()
            }.share()

        similarMoviesEvent
            .sink(receiveCompletion: { [weak self] completionReceived in
                guard let `self` = self else { return }

                switch completionReceived {
                    case .failure(let error):
                        print("🔴 [MovieDetailsVM] [init] Received completion error. Error: \(error.localizedDescription)")
                        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] movieDetails in
                guard let `self` = self else { return }
                self.similarMoviesActionProperty.value = movieDetails.movies
            }).store(in: &cancellable)
	}

	// MARK: - ⬇️ INPUTS Definition
	private let viewDidLoadProperty = PassthroughSubject<Void, Never>()
	public func viewDidLoad() {
		viewDidLoadProperty.send(())
	}

	private let closeButtonPressedProperty = PassthroughSubject<Void, Never>()
	public func closeButtonPressed() {
		closeButtonPressedProperty.send(())
	}

    private let backdropImageSelectedProperty = PassthroughSubject<String, Never>()
    public func backdropImageSelected(imageURL: String) {
        backdropImageSelectedProperty.send(imageURL)
    }

    private let socialNetworkSelectedProperty = PassthroughSubject<SocialNetwork, Never>()
    public func socialNetworkSelected(socialNetwork: SocialNetwork) {
        socialNetworkSelectedProperty.send(socialNetwork)
    }

    private let galleryButtonPressedProperty = PassthroughSubject<Void, Never>()
    public func galleryButtonPressed() {
        galleryButtonPressedProperty.send(())
    }

    private let castMemberSelectedProperty = PassthroughSubject<Cast, Never>()
    public func castMemberSelected(cast: Cast) {
        castMemberSelectedProperty.send(cast)
    }

    private let creditsButtonPressedProperty = PassthroughSubject<Void, Never>()
    public func creditsButtonPressed() {
        creditsButtonPressedProperty.send(())
    }

    private let overviewTextPressedProperty = PassthroughSubject<Void, Never>()
    public func overviewTextPressed() {
        overviewTextPressedProperty.send()
    }

    private let movieSelectedProperty = PassthroughSubject<Movie, Never>()
    public func movieSelected(movie: Movie) {
        movieSelectedProperty.send(movie)
    }

    private let favoriteButtonPressedProperty = PassthroughSubject<Movie, Never>()
    public func favoriteButtonPressed(movie: Movie) {
        favoriteButtonPressedProperty.send(movie)
    }

	// MARK: - ⬆️ OUTPUTS Definition
	private let closeButtonActionProperty = PassthroughSubject<Void, Never>()
	public func closeButtonAction() -> PassthroughSubject<Void, Never> {
		return closeButtonActionProperty
	}

	private let movieInfoActionProperty = PassthroughSubject<Movie, Never>()
	public func movieInfoAction() -> PassthroughSubject<Movie, Never> {
		return movieInfoActionProperty
	}

	private let loadingProperty = CurrentValueSubject<Bool, Never>(false)
	public func loading() -> CurrentValueSubject<Bool, Never> {
		return loadingProperty
	}

    private let showErrorProperty = PassthroughSubject<String, Never>()
    public func showError() -> PassthroughSubject<String, Never> {
        return showErrorProperty
    }

    private let socialNetworksActionProperty = CurrentValueSubject<SocialNetworks?, Never>(nil)
    public func socialNetworksAction() -> CurrentValueSubject<SocialNetworks?, Never> {
        return socialNetworksActionProperty
    }

    private let galleryButtonActionProperty = PassthroughSubject<Void, Never>()
    public func galleryButtonAction() -> PassthroughSubject<Void, Never> {
        return galleryButtonActionProperty
    }

    private let creditsActionProperty = CurrentValueSubject<Credits?, Never>(nil)
    public func creditsAction() -> CurrentValueSubject<Credits?, Never> {
        return creditsActionProperty
    }

    private let castMemberActionProperty = PassthroughSubject<Person, Never>()
    public func castMemberAction() -> PassthroughSubject<Person, Never> {
        return castMemberActionProperty
    }

    private let creditsButtonActionProperty = PassthroughSubject<(Movie, Credits), Never>()
    public func creditsButtonAction() -> PassthroughSubject<(Movie, Credits), Never> {
        return creditsButtonActionProperty
    }

    private let overviewTextActionProperty = PassthroughSubject<String, Never>()
    public func overviewTextAction() -> PassthroughSubject<String, Never> {
        return overviewTextActionProperty
    }

    private let movieSelectedActionProperty = PassthroughSubject<Movie, Never>()
    public func movieSelectedAction() -> PassthroughSubject<Movie, Never> {
        return movieSelectedActionProperty
    }

    private let similarMoviesActionProperty = CurrentValueSubject<[Movie]?, Never>([])
    public func similarMoviesAction() -> CurrentValueSubject<[Movie]?, Never> {
        return similarMoviesActionProperty
    }

    private let favoriteChangedProperty = CurrentValueSubject<Bool, Never>(false)
    public func favoriteChanged() -> CurrentValueSubject<Bool, Never> {
        return favoriteChangedProperty
    }

	// MARK: - ⚙️ Helpers
    private func handleNetworkResponseError(_ networkResponse: NetworkResponse) {
        print("❌ Network response error: \(networkResponse.localizedDescription)")
        self.showErrorProperty.send(NSLocalizedString("network_response_error", comment: "Network response error"))
    }

    private func handleIsFavorite(movie: Movie) -> Bool {
        let response = storageService.find(movie: movie)
        return response
    }

    private func handleFavoriteChange(movie: Movie) -> Bool {
        do {
            let isFavorite = storageService.find(movie: movie)

            if !isFavorite {
                storageService.create(movie: movie)
                return true

            } else {
                try storageService.delete(movie: movie)
                return false
            }

        } catch let error as NSError {
            print("❌ [UI] [Screens] [MovieDetailsVM] [handleFavoriteChange] An error occurred. \(error.localizedDescription)")
            return false
        }
    }

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑", "MovieDetailsVM deinit.")
	}
}
