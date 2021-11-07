//
//  MovieDetailsVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 7/10/21.
//

import Foundation
import Combine

public protocol MovieDetailsVMInputs: AnyObject {
	/// Call when the view did load.
	func viewDidLoad()

	/// Call when the close button is pressed.
	func closeButtonPressed()

    /// Call when an backdrop image is selected from the movie details.
    func backdropImageSelected(imageURL: String)
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
                print(socialNetworks.instagramId ?? "no insta")
                
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
