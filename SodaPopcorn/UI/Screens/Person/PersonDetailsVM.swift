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
    func movieSelected(movie: Movie)

    /// Call when the person's biography is pressed.
    func biographyTextPressed()

    /// Call when user press more movies button.
    func personMoviesButtonPressed()

    /// Call when a person image is selected.
    func personImageSelected(personImage: PersonImage)

    /// Call when the user selects person gallery.
    func personGallerySelected()
}

public protocol PersonDetailsVMOutputs: AnyObject {
    /// Emits to close the screen.
    func closeButtonAction() -> PassthroughSubject<Void, Never>

    /// Emits to get return the movie information.
    func personInfoAction() -> CurrentValueSubject<Person, Never>

    /// Emits when loading.
    func loading() -> CurrentValueSubject<Bool, Never>

    /// Emits when an error occurred.
    func showError() -> PassthroughSubject<String, Never>

    /// Emits when the person's biography is pressed.
    func biographyTextAction() -> PassthroughSubject<String, Never>

    /// Emits to get the person's movies.
    func fetchPersonMoviesAction() -> CurrentValueSubject<[Movie], Never>

    /// Emits when user press more movies button.
    func personMoviesButtonAction() -> PassthroughSubject<([Movie], Person), Never>

    /// Emits when a movie is selected.
    func movieSelectedAction() -> PassthroughSubject<Movie, Never>

    /// Emits when the social networks are fetched.
    func socialNetworksAction() -> CurrentValueSubject<SocialNetworks?, Never>

    /// Emits to return the person images.
    func personImagesAction() -> CurrentValueSubject<[PersonImage]?, Never>

    /// Emits when the user selects person gallery.
    func personGallerySelectedAction() -> PassthroughSubject<(Person, [PersonImage]), Never>

    /// Emits when a person image is selected.
    func personImageAction() -> PassthroughSubject<PersonImage, Never>
}

public protocol PersonDetailsVMTypes: AnyObject {
    var inputs: PersonDetailsVMInputs { get }
    var outputs: PersonDetailsVMOutputs { get }
}

public final class PersonDetailsVM: ObservableObject, Identifiable, PersonDetailsVMInputs, PersonDetailsVMOutputs, PersonDetailsVMTypes {
    // MARK: Constants
    private let movieService: MovieService
    private let person: Person

    // MARK: Variables
    public var inputs: PersonDetailsVMInputs { return self }
    public var outputs: PersonDetailsVMOutputs { return self }

    // MARK: Variables
    private var cancellable = Set<AnyCancellable>()

    init(movieService: MovieService, person: Person) {
        self.movieService = movieService
        self.person = person

        movieSelectedProperty.sink { [weak self] (movie) in
            self?.movieSelectedActionProperty.send(movie)
        }.store(in: &cancellable)

        closeButtonPressedProperty.sink { [weak self] _ in
            self?.closeButtonActionProperty.send(())
        }.store(in: &cancellable)

        biographyTextPressedProperty.sink { [weak self] (_) in
            guard let `self` = self else { return }
            if let biography = self.personInfoActionProperty.value.biography {
                self.biographyTextActionProperty.send(biography)
            }
        }.store(in: &cancellable)

        personMoviesButtonPressedProperty.sink { [weak self] _ in
            guard let `self` = self else { return }

            let movies = self.fetchPersonMoviesActionProperty.value
            if !movies.isEmpty {
                self.personMoviesButtonActionProperty.send((movies, self.person))
            }
        }.store(in: &cancellable)

        personImageSelectedProperty.sink { [weak self] personImage in
            self?.personImageActionProperty.send(personImage)
        }.store(in: &cancellable)

        personGallerySelectedProperty.sink { [weak self] _ in
            if let personGallery = self?.personImagesActionProperty.value, let person = self?.person {
                self?.personGallerySelectedActionProperty.send((person, personGallery))
            }
        }.store(in: &cancellable)

        let personDetailsEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<Person, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                self.loadingProperty.value = true

                return movieService.personDetails(personId: String(self.person.id ?? 0))
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
                self.personInfoActionProperty.value = personDetails
            }).store(in: &cancellable)

        let personCreditsEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<[Movie], Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                return movieService.personMovieCredits(personId: (self.person.id ?? 0).description)
                    .mapError({ [weak self] networkResponse -> NetworkResponse in
                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")

                        self?.handleNetworkResponseError(networkResponse)
                        return networkResponse
                    })
                    .replaceError(with: [Movie]())
                    .eraseToAnyPublisher()
            }.share()

        personCreditsEvent
            .sink(receiveCompletion: { [weak self] completionReceived in
                guard let `self` = self else { return }

                switch completionReceived {
                    case .failure(let error):
                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(error.localizedDescription)")
                        self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] movies in
                guard let `self` = self else { return }
                self.fetchPersonMoviesActionProperty.value = movies

            }).store(in: &cancellable)

        let socialNetworksEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<SocialNetworks, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                return movieService.personExternalIds(personId: (self.person.id ?? 0).description)
                    .mapError({ [weak self] networkResponse -> NetworkResponse in
                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")

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
                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(error.localizedDescription)")
                        self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] socialNetworks in
                guard let `self` = self else { return }
                self.socialNetworksActionProperty.value = socialNetworks

            }).store(in: &cancellable)

        let imagesEvent = viewDidLoadProperty
            .flatMap { [weak self] _ -> AnyPublisher<PersonImages, Never> in
                guard let `self` = self else { return Empty(completeImmediately: true).eraseToAnyPublisher() }

                return movieService.personImages(personId: (self.person.id ?? 0).description)
                    .mapError({ [weak self] networkResponse -> NetworkResponse in
                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(networkResponse.localizedDescription)")

                        self?.handleNetworkResponseError(networkResponse)
                        return networkResponse
                    })
                    .replaceError(with: PersonImages())
                    .eraseToAnyPublisher()
            }.share()

        imagesEvent
            .sink(receiveCompletion: { [weak self] completionReceived in
                guard let `self` = self else { return }

                switch completionReceived {
                    case .failure(let error):
                        print("🔴 [PersonDetailsVM] [init] Received completion error. Error: \(error.localizedDescription)")
                        self.showErrorProperty.send(NSLocalizedString("network_connection_error", comment: "Network error message"))
                    default: break
                }
            }, receiveValue: { [weak self] personImages in
                guard let `self` = self else { return }
                if let images = personImages.images {
                    self.personImagesActionProperty.value = images
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

    private let movieSelectedProperty = PassthroughSubject<Movie, Never>()
    public func movieSelected(movie: Movie) {
        movieSelectedProperty.send(movie)
    }

    private let biographyTextPressedProperty = PassthroughSubject<Void, Never>()
    public func biographyTextPressed() {
        biographyTextPressedProperty.send(())
    }

    private let personMoviesButtonPressedProperty = PassthroughSubject<Void, Never>()
    public func personMoviesButtonPressed() {
        personMoviesButtonPressedProperty.send(())
    }

    private let personImageSelectedProperty = PassthroughSubject<PersonImage, Never>()
    public func personImageSelected(personImage: PersonImage) {
        personImageSelectedProperty.send(personImage)
    }

    private let personGallerySelectedProperty = PassthroughSubject<Void, Never>()
    public func personGallerySelected() {
        personGallerySelectedProperty.send(())
    }

    // MARK: - ⬆️ OUTPUTS Definition
    private let closeButtonActionProperty = PassthroughSubject<Void, Never>()
    public func closeButtonAction() -> PassthroughSubject<Void, Never> {
        return closeButtonActionProperty
    }

    private let personInfoActionProperty = CurrentValueSubject<Person, Never>(Person())
    public func personInfoAction() -> CurrentValueSubject<Person, Never> {
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

    private let fetchPersonMoviesActionProperty = CurrentValueSubject<[Movie], Never>([])
    public func fetchPersonMoviesAction() -> CurrentValueSubject<[Movie], Never> {
        return fetchPersonMoviesActionProperty
    }

    private let personMoviesButtonActionProperty = PassthroughSubject<([Movie], Person), Never>()
    public func personMoviesButtonAction() -> PassthroughSubject<([Movie], Person), Never> {
        return personMoviesButtonActionProperty
    }

    private let movieSelectedActionProperty = PassthroughSubject<Movie, Never>()
    public func movieSelectedAction() -> PassthroughSubject<Movie, Never> {
        return movieSelectedActionProperty
    }

    private let socialNetworksActionProperty = CurrentValueSubject<SocialNetworks?, Never>(nil)
    public func socialNetworksAction() -> CurrentValueSubject<SocialNetworks?, Never> {
        return socialNetworksActionProperty
    }

    private let personImagesActionProperty = CurrentValueSubject<[PersonImage]?, Never>([])
    public func personImagesAction() -> CurrentValueSubject<[PersonImage]?, Never> {
        return personImagesActionProperty
    }

    private let personImageActionProperty = PassthroughSubject<PersonImage, Never>()
    public func personImageAction() -> PassthroughSubject<PersonImage, Never> {
        return personImageActionProperty
    }

    private let personGallerySelectedActionProperty = PassthroughSubject<(Person, [PersonImage]), Never>()
    public func personGallerySelectedAction() -> PassthroughSubject<(Person, [PersonImage]), Never> {
        return personGallerySelectedActionProperty
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
