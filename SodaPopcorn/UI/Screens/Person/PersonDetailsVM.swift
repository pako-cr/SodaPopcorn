//
//  PersonDetailsVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

import Combine
import Foundation

public protocol PersonDetailsVMInputs: AnyObject {
    /// Call when the view did load.
    func viewDidLoad()

    /// Call when the close button is pressed.
    func closeButtonPressed()

    /// Call when a movie is selected from the person details.
    func movieSelected(movieId: String)

    /// Call when the person's biography is pressed.
    func biographyTextPressed(biography: String)
}

public protocol PersonDetailsVMOutputs: AnyObject {
    /// Emits to close the screen.
    func closeButtonAction() -> PassthroughSubject<Void, Never>

    /// Emits to get return the movie information.
    func personInfoAction() -> PassthroughSubject<Person, Never>

    /// Emits when loading.
    func loading() -> CurrentValueSubject<Bool, Never>

    /// Emits when an error occurred.
    func showError() -> PassthroughSubject<String, Never>

    /// Emits when the person's biography is pressed.
    func biographyTextAction() -> PassthroughSubject<String, Never>
}

public protocol PersonDetailsVMTypes: AnyObject {
    var inputs: PersonDetailsVMInputs { get }
    var outputs: PersonDetailsVMOutputs { get }
}

public final class PersonDetailsVM: ObservableObject, Identifiable, PersonDetailsVMInputs, PersonDetailsVMOutputs, PersonDetailsVMTypes {
    // MARK: Constants
    private let movieService: MovieService
    private let personId: String

    // MARK: Variables
    public var inputs: PersonDetailsVMInputs { return self }
    public var outputs: PersonDetailsVMOutputs { return self }

    // MARK: Variables
    private var cancellable = Set<AnyCancellable>()

    init(movieService: MovieService, personId: String) {
        self.movieService = movieService
        self.personId = personId

//        movieSelectedProperty.sink { [weak self] (movieId) in
//
//        }.store(in: &cancellable)
//
        biographyTextPressedProperty.sink { [weak self] (biography) in
            self?.biographyTextActionProperty.send(biography)
        }.store(in: &cancellable)

        let personDetailsEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<Person, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                self.loadingProperty.value = true

                return movieService.personDetails(personId: self.personId)
                    .mapError({ [weak self] networkResponse -> NetworkResponse in
                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")
                        self?.loadingProperty.value = false
                        self?.handleNetworkResponseError(networkResponse)
                        return networkResponse
                    })
                    .replaceError(with: Person())
                    .eraseToAnyPublisher()
            }.share()

        personDetailsEvent
            .sink(receiveCompletion: { [weak self] completionReceived in
                guard let `self` = self else { return }

                self.loadingProperty.value = false

                switch completionReceived {
                    case .failure(let error):
                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(error.localizedDescription)")
                        self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] personDetails in
                guard let `self` = self else { return }

                self.loadingProperty.value = false
                self.personInfoActionProperty.send(personDetails)
            }).store(in: &cancellable)

//        let imagesEvent = viewDidLoadProperty
//            .flatMap { [weak self] _ -> AnyPublisher<MovieImages, Never> in
//                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }
//
//                return movieService.getImages(movieId: self.movie.id ?? "")
//                    .mapError({ [weak self] networkResponse -> NetworkResponse in
//                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")
//
//                        self?.handleNetworkResponseError(networkResponse)
//                        return networkResponse
//                    })
//                    .replaceError(with: MovieImages())
//                    .eraseToAnyPublisher()
//            }.share()
//
//        imagesEvent
//            .sink(receiveCompletion: { [weak self] completionReceived in
//                guard let `self` = self else { return }
//
//                switch completionReceived {
//                    case .failure(let error):
//                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(error.localizedDescription)")
//                        self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
//                    default: break
//                }
//            }, receiveValue: { [weak self] movieImages in
//                guard let `self` = self else { return }
//
//                if let backdrops = movieImages.backdrops, !backdrops.isEmpty {
//                    self.backdropImagesActionProperty.send(backdrops.filter({ $0.filePath != self.movie.backdropPath }))
//                }
//            }).store(in: &cancellable)

//        let socialNetworksEvent = viewDidLoadProperty
//            .flatMap { [weak self] _ -> AnyPublisher<SocialNetworks, Never> in
//                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }
//
//                return movieService.socialNetworks(movieId: self.movie.id ?? "")
//                    .mapError({ [weak self] networkResponse -> NetworkResponse in
//                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")
//
//                        self?.handleNetworkResponseError(networkResponse)
//                        return networkResponse
//                    })
//                    .replaceError(with: SocialNetworks())
//                    .eraseToAnyPublisher()
//            }.share()
//
//        socialNetworksEvent
//            .sink(receiveCompletion: { [weak self] completionReceived in
//                guard let `self` = self else { return }
//
//                switch completionReceived {
//                    case .failure(let error):
//                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(error.localizedDescription)")
//                        self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
//                    default: break
//                }
//            }, receiveValue: { [weak self] socialNetworks in
//                guard let `self` = self else { return }
//                self.socialNetworksActionProperty.send(socialNetworks)
//            }).store(in: &cancellable)
//
//        let creditsEvent = viewDidLoadProperty
//            .flatMap { [weak self] _ -> AnyPublisher<Credits, Never> in
//                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }
//
//                return movieService.movieCredits(movieId: self.movie.id ?? "")
//                    .mapError({ [weak self] networkResponse -> NetworkResponse in
//                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")
//
//                        self?.handleNetworkResponseError(networkResponse)
//                        return networkResponse
//                    })
//                    .replaceError(with: Credits())
//                    .eraseToAnyPublisher()
//            }.share()
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

    private let movieSelectedProperty = PassthroughSubject<String, Never>()
    public func movieSelected(movieId: String) {
        movieSelectedProperty.send(movieId)
    }

    private let biographyTextPressedProperty = PassthroughSubject<String, Never>()
    public func biographyTextPressed(biography: String) {
        biographyTextPressedProperty.send(biography)
    }

    // MARK: - ⬆️ OUTPUTS Definition
    private let closeButtonActionProperty = PassthroughSubject<Void, Never>()
    public func closeButtonAction() -> PassthroughSubject<Void, Never> {
        return closeButtonActionProperty
    }

    private let personInfoActionProperty = PassthroughSubject<Person, Never>()
    public func personInfoAction() -> PassthroughSubject<Person, Never> {
        return personInfoActionProperty
    }

    private let loadingProperty = CurrentValueSubject<Bool, Never>(false)
    public func loading() -> CurrentValueSubject<Bool, Never> {
        return loadingProperty
    }

    private let showErrorProperty = PassthroughSubject<String, Never>()
    public func showError() -> PassthroughSubject<String, Never> {
        return showErrorProperty
    }

    private let biographyTextActionProperty = PassthroughSubject<String, Never>()
    public func biographyTextAction() -> PassthroughSubject<String, Never> {
        return biographyTextActionProperty
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
        print("🗑", "PersonDetailsVM deinit.")
    }
}
