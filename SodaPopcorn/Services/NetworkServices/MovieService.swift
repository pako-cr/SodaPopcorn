//
//  MovieService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Combine
import Foundation
import Networking

public final class MovieService: MovieNetworkServiceProtocol {
    private let movieNetworkService: Networking.MovieNetworkService

    private var cancellable = Set<AnyCancellable>()

	private static let sharedMovieService: MovieService = {
		return MovieService(movieNetworkService: MovieNetworkService())
	}()

	private init(movieNetworkService: MovieNetworkService) {
		self.movieNetworkService = movieNetworkService
	}

	static func shared() -> MovieService {
		return sharedMovieService
	}

	// MARK: - Public Methods
    public func movies(page: Int, searchCriteria: SearchCriteria) -> AnyPublisher<Movies, NetworkResponse> {
        return AnyPublisher<Movies, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            let searchCriteriaApiRequest = SearchCriteriaApiRequest(searchCriteria: searchCriteria)

            self.moviesApi(page: page, searchCriteria: searchCriteriaApiRequest)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = Movies(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func movieDetails(movieId: String) -> AnyPublisher<Movie, NetworkResponse> {
        return AnyPublisher<Movie, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.movieDetailsApi(movieId: movieId)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = Movie(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func movieImages(movieId: String) -> AnyPublisher<MovieImages, NetworkResponse> {
        return AnyPublisher<MovieImages, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.movieImagesApi(movieId: movieId)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = MovieImages(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func movieExternalIds(movieId: String) -> AnyPublisher<SocialNetworks, NetworkResponse> {
        return AnyPublisher<SocialNetworks, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.movieExternalIdsApi(movieId: movieId)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = SocialNetworks(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func movieVideos(movieId: String) -> AnyPublisher<Videos, NetworkResponse> {
        return AnyPublisher<Videos, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.movieVideosApi(movieId: movieId)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = Videos(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func movieCredits(movieId: String) -> AnyPublisher<Credits, NetworkResponse> {
        return AnyPublisher<Credits, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.movieCreditsApi(movieId: movieId)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = Credits(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func movieSimilarMovies(movieId: String, page: Int? = nil) -> AnyPublisher<Movies, NetworkResponse> {
        return AnyPublisher<Movies, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.movieSimilarMoviesApi(movieId: movieId, page: page)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = Movies(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func genresList() -> AnyPublisher<Genres, NetworkResponse> {
        return AnyPublisher<Genres, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.genresListApi()
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = Genres(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func searchMovie(query: String, page: Int) -> AnyPublisher<Movies, NetworkResponse> {
        return AnyPublisher<Movies, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.searchMovieApi(query: query, page: page)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = Movies(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func discover(genre: Int, page: Int) -> AnyPublisher<Movies, NetworkResponse> {
        return AnyPublisher<Movies, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.discoverApi(genre: genre, page: page)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = Movies(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func personDetails(personId: String) -> AnyPublisher<Person, NetworkResponse> {
        return AnyPublisher<Person, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.personDetailsApi(personId: personId)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = Person(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func personMovieCredits(personId: String) -> AnyPublisher<[Movie], NetworkResponse> {
        return AnyPublisher<[Movie], NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.personMovieCreditsApi(personId: personId)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = PersonInMovie(apiResponse: apiResponse)

                    if let movies = response.cast {
                        promise.onNext(movies)
                    }
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func personExternalIds(personId: String) -> AnyPublisher<SocialNetworks, NetworkResponse> {
        return AnyPublisher<SocialNetworks, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.personExternalIdsApi(personId: personId)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = SocialNetworks(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    public func personImages(personId: String) -> AnyPublisher<PersonImages, NetworkResponse> {
        return AnyPublisher<PersonImages, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.personImagesApi(personId: personId)
                .sink(receiveCompletion: { [weak self] networkResponse in
                    guard let `self` = self else { return }
                    switch networkResponse {
                    case .failure(let response):
                        let newNetworkResponse = self.handleNetworkResponse(networkResponseApi: response)
                        promise.onError(newNetworkResponse)
                    default: break
                    }
                }, receiveValue: { apiResponse in
                    let response = PersonImages(apiResponse: apiResponse)
                    promise.onNext(response)
                }).store(in: &self.cancellable)

            return Disposable()
        }
    }

    // MARK: - Network Service
    // MARK: Movies
    public func moviesApi(page: Int, searchCriteria: SearchCriteriaApiRequest) -> AnyPublisher<MoviesApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.moviesApi(page: page, searchCriteria: searchCriteria)
    }

    public func movieDetailsApi(movieId: String) -> AnyPublisher<MovieApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.movieDetailsApi(movieId: movieId)
    }

    public func movieImagesApi(movieId: String) -> AnyPublisher<ImagesApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.movieImagesApi(movieId: movieId)
    }

    public func movieExternalIdsApi(movieId: String) -> AnyPublisher<SocialNetworksApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.movieExternalIdsApi(movieId: movieId)
    }

    public func movieVideosApi(movieId: String) -> AnyPublisher<VideosApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.movieVideosApi(movieId: movieId)
    }

    public func movieCreditsApi(movieId: String) -> AnyPublisher<CreditsApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.movieCreditsApi(movieId: movieId)
    }

    public func movieSimilarMoviesApi(movieId: String, page: Int? = nil) -> AnyPublisher<MoviesApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.movieSimilarMoviesApi(movieId: movieId, page: page)
    }

    public func genresListApi() -> AnyPublisher<GenresApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.genresListApi()
    }

    public func searchMovieApi(query: String, page: Int) -> AnyPublisher<MoviesApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.searchMovieApi(query: query, page: page)
    }

    public func discoverApi(genre: Int, page: Int) -> AnyPublisher<MoviesApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.discoverApi(genre: genre, page: page)
    }

    // MARK: Person
    public func personDetailsApi(personId: String) -> AnyPublisher<PersonApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.personDetailsApi(personId: personId)
    }

    public func personMovieCreditsApi(personId: String) -> AnyPublisher<PersonInMovieApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.personMovieCreditsApi(personId: personId)
    }

    public func personExternalIdsApi(personId: String) -> AnyPublisher<SocialNetworksApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.personExternalIdsApi(personId: personId)
    }

    public func personImagesApi(personId: String) -> AnyPublisher<PersonImagesApiResponse, NetworkResponseApi> {
        return self.movieNetworkService.personImagesApi(personId: personId)
    }

    // MARK: - Helpers
    private func handleNetworkResponse(networkResponseApi: NetworkResponseApi) -> NetworkResponse {
        var newNetworkResponse: NetworkResponse

        switch networkResponseApi {
        case .authenticationError:
            newNetworkResponse = .authenticationError
        case .success(let response):
            newNetworkResponse = .success(response)
        case .badRequest:
            newNetworkResponse = .badRequest
        case .outdated:
            newNetworkResponse = .outdated
        case .failed(let error):
            newNetworkResponse = .failed(error)
        case .noData:
            newNetworkResponse = .noData
        case .unableToDecode:
            newNetworkResponse = .unableToDecode
        }

        return newNetworkResponse
    }
}
