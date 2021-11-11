//
//  MovieDetailsVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 7/10/21.
//

import Combine
import Foundation

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

    /// Emits when an backdrop image is selected from the movie details.
    func backdropImageAction() -> PassthroughSubject<String, Never>

    /// Emits when the backdrop images are fetched.
    func backdropImagesAction() -> PassthroughSubject<[Backdrop], Never>

    /// Emits when the cast information is fetched.
    func castAction() -> PassthroughSubject<[Cast], Never>

    /// Emits when the social networks are fetched.
    func socialNetworksAction() -> PassthroughSubject<SocialNetworks, Never>

    /// Emits when the gallery button is pressed.
    func galleryButtonAction() -> PassthroughSubject<Void, Never>

    /// Emits when a cast member is selected.
    func castMemberAction() -> PassthroughSubject<Cast, Never>

    /// Emits when the credits button is pressed.
    func creditsButtonAction() -> PassthroughSubject<Credits, Never>
}

public protocol MovieDetailsVMTypes: AnyObject {
	var inputs: MovieDetailsVMInputs { get }
	var outputs: MovieDetailsVMOutputs { get }
}

public final class MovieDetailsVM: ObservableObject, Identifiable, MovieDetailsVMInputs, MovieDetailsVMOutputs, MovieDetailsVMTypes {
	// MARK: Constants
    private let movieService: MovieService
    private let movie: Movie

	// MARK: Variables
	public var inputs: MovieDetailsVMInputs { return self }
	public var outputs: MovieDetailsVMOutputs { return self }

	// MARK: Variables
	private var cancellable = Set<AnyCancellable>()
	private var page = 0
    private var credits: Credits?

    init(movieService: MovieService, movie: Movie) {
        self.movieService = movieService
		self.movie = movie

		viewDidLoadProperty.sink { [weak self] _ in
			guard let `self` = self else { return }
            self.movieInfoActionProperty.send(self.movie)
		}.store(in: &cancellable)

		closeButtonPressedProperty.sink { [weak self] _ in
			self?.closeButtonActionProperty.send(())
		}.store(in: &cancellable)

        backdropImageSelectedProperty.sink { [weak self] (imageURL) in
            self?.backdropImageActionProperty.send(imageURL)
        }.store(in: &cancellable)

        galleryButtonPressedProperty.sink { [weak self] _ in
            guard let `self` = self else { return }
            self.galleryButtonActionProperty.send(())
        }.store(in: &cancellable)

        castMemberSelectedProperty.sink { [weak self] cast in
            self?.castMemberActionProperty.send(cast)
        }.store(in: &cancellable)

        creditsButtonPressedProperty.sink { [weak self] _ in
            if let credits = self?.credits {
                self?.creditsButtonActionProperty.send(credits)
            }
        }.store(in: &cancellable)

        let movieDetailsEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<Movie, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                self.loadingProperty.value = true

                return movieService.movieDetails(movieId: self.movie.id ?? "")
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
                        self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] movieDetails in
                guard let `self` = self else { return }

                self.loadingProperty.value = false

                self.movieInfoActionProperty.send(movieDetails)
            }).store(in: &cancellable)

        let imagesEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<MovieImages, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                return movieService.getImages(movieId: self.movie.id ?? "")
                    .mapError({ [weak self] networkResponse -> NetworkResponse in
                        print("🔴 [MovieDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")

                        self?.handleNetworkResponseError(networkResponse)
                        return networkResponse
                    })
                    .replaceError(with: MovieImages())
                    .eraseToAnyPublisher()
            }.share()

        imagesEvent
            .sink(receiveCompletion: { [weak self] completionReceived in
                guard let `self` = self else { return }

                switch completionReceived {
                    case .failure(let error):
                        print("🔴 [MovieDetailsVM] [init] Received completion error. Error: \(error.localizedDescription)")
                        self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] movieImages in
                guard let `self` = self else { return }

                if let backdrops = movieImages.backdrops, !backdrops.isEmpty {
                    self.backdropImagesActionProperty.send(backdrops.filter({ $0.filePath != self.movie.backdropPath }))
                }
            }).store(in: &cancellable)

        let socialNetworksEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<SocialNetworks, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                return movieService.socialNetworks(movieId: self.movie.id ?? "")
                    .mapError({ [weak self] networkResponse -> NetworkResponse in
                        print("🔴 [MovieDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")

                        self?.handleNetworkResponseError(networkResponse)
                        return networkResponse
                    })
                    .replaceError(with: SocialNetworks())
                    .eraseToAnyPublisher()
            }.share()

        socialNetworksEvent
            .sink(receiveCompletion: { [weak self] completionReceived in
                guard let `self` = self else { return }

                switch completionReceived {
                    case .failure(let error):
                        print("🔴 [MovieDetailsVM] [init] Received completion error. Error: \(error.localizedDescription)")
                        self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] socialNetworks in
                guard let `self` = self else { return }
                self.socialNetworksActionProperty.send(socialNetworks)
            }).store(in: &cancellable)

        let creditsEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<Credits, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                return movieService.movieCredits(movieId: self.movie.id ?? "")
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
                        self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] credits in
                guard let `self` = self else { return }

                self.credits = credits
                if let cast = credits.cast {
                    self.castActionProperty.send(cast)
                }
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

    private let backdropImageActionProperty = PassthroughSubject<String, Never>()
    public func backdropImageAction() -> PassthroughSubject<String, Never> {
        return backdropImageActionProperty
    }

    private let backdropImagesActionProperty = PassthroughSubject<[Backdrop], Never>()
    public func backdropImagesAction() -> PassthroughSubject<[Backdrop], Never> {
        return backdropImagesActionProperty
    }

    private let socialNetworksActionProperty = PassthroughSubject<SocialNetworks, Never>()
    public func socialNetworksAction() -> PassthroughSubject<SocialNetworks, Never> {
        return socialNetworksActionProperty
    }

    private let galleryButtonActionProperty = PassthroughSubject<Void, Never>()
    public func galleryButtonAction() -> PassthroughSubject<Void, Never> {
        return galleryButtonActionProperty
    }

    private let castActionProperty = PassthroughSubject<[Cast], Never>()
    public func castAction() -> PassthroughSubject<[Cast], Never> {
        return castActionProperty
    }

    private let castMemberActionProperty = PassthroughSubject<Cast, Never>()
    public func castMemberAction() -> PassthroughSubject<Cast, Never> {
        return castMemberActionProperty
    }

    private let creditsButtonActionProperty = PassthroughSubject<Credits, Never>()
    public func creditsButtonAction() -> PassthroughSubject<Credits, Never> {
        return creditsButtonActionProperty
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
		print("🗑", "MovieDetailsVM deinit.")
	}
}
