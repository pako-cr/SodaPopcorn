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

    /// Call when the movie's overview is pressed.
    func overviewTextPressed()
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

    /// Emits when the credits information is fetched.
    func creditsAction() -> CurrentValueSubject<Credits?, Never>

    /// Emits when the social networks are fetched.
    func socialNetworksAction() -> CurrentValueSubject<SocialNetworks?, Never>

    /// Emits when the gallery button is pressed.
    func galleryButtonAction() -> PassthroughSubject<Void, Never>

    /// Emits when a cast member is selected.
    func castMemberAction() -> PassthroughSubject<Person, Never>

    /// Emits when the credits button is pressed.
    func creditsButtonAction() -> PassthroughSubject<Credits, Never>

    /// Emits when the movie's overview is pressed.
    func overviewTextAction() -> PassthroughSubject<String, Never>
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
            let person = Person(name: cast.name, id: cast.id)
            self?.castMemberActionProperty.send(person)
        }.store(in: &cancellable)

        creditsButtonPressedProperty.sink { [weak self] _ in
            if let credits = self?.creditsActionProperty.value {
                self?.creditsButtonActionProperty.send(credits)
            }
        }.store(in: &cancellable)

        overviewTextPressedProperty.sink { [weak self] (overview) in
            guard let `self` = self, let overview = self.movie.overview else { return }
            self.overviewTextActionProperty.send(overview)
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

                return movieService.movieImages(movieId: self.movie.id ?? "")
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

        let movieExternalIdsEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<SocialNetworks, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                return movieService.movieExternalIds(movieId: self.movie.id ?? "")
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
                        self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] socialNetworks in
                guard let `self` = self else { return }
                self.socialNetworksActionProperty.value = socialNetworks

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
                self.creditsActionProperty.value = credits

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

    private let creditsButtonActionProperty = PassthroughSubject<Credits, Never>()
    public func creditsButtonAction() -> PassthroughSubject<Credits, Never> {
        return creditsButtonActionProperty
    }

    private let overviewTextActionProperty = PassthroughSubject<String, Never>()
    public func overviewTextAction() -> PassthroughSubject<String, Never> {
        return overviewTextActionProperty
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
