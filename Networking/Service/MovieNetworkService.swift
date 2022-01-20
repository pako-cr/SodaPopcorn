//
//  MovieNetworkService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Combine
import Foundation

public protocol MovieNetworkServiceProtocol {
    func moviesApi(page: Int, searchCriteria: SearchCriteriaApiRequest) -> AnyPublisher<MoviesApiResponse, NetworkResponseApi>
    func movieDetailsApi(movieId: String) -> AnyPublisher<MovieApiResponse, NetworkResponseApi>
    func movieImagesApi(movieId: String) -> AnyPublisher<ImagesApiResponse, NetworkResponseApi>
    func movieExternalIdsApi(movieId: String) -> AnyPublisher<SocialNetworksApiResponse, NetworkResponseApi>
    func movieVideosApi(movieId: String) -> AnyPublisher<VideosApiResponse, NetworkResponseApi>
    func movieCreditsApi(movieId: String) -> AnyPublisher<CreditsApiResponse, NetworkResponseApi>
    func movieSimilarMoviesApi(movieId: String, page: Int?) -> AnyPublisher<MoviesApiResponse, NetworkResponseApi>
    func genresListApi() -> AnyPublisher<GenresApiResponse, NetworkResponseApi>
    func searchMovieApi(query: String, page: Int) -> AnyPublisher<MoviesApiResponse, NetworkResponseApi>
    func discoverApi(genre: Int, page: Int) -> AnyPublisher<MoviesApiResponse, NetworkResponseApi>

    func personDetailsApi(personId: String) -> AnyPublisher<PersonApiResponse, NetworkResponseApi>
    func personMovieCreditsApi(personId: String) -> AnyPublisher<PersonInMovieApiResponse, NetworkResponseApi>
    func personExternalIdsApi(personId: String) -> AnyPublisher<SocialNetworksApiResponse, NetworkResponseApi>
    func personImagesApi(personId: String) -> AnyPublisher<PersonImagesApiResponse, NetworkResponseApi>
}

public final class MovieNetworkService: MovieNetworkServiceProtocol {
	private let networkManager = NetworkManager<MovieApiEndpoint>()

    public init() {
        
    }

    // MARK: - Movies
    public func moviesApi(page: Int, searchCriteria: SearchCriteriaApiRequest = .nowPlaying) -> AnyPublisher<MoviesApiResponse, NetworkResponseApi> {
        return AnyPublisher<MoviesApiResponse, NetworkResponseApi>.create { [weak self] promise in
			guard let `self` = self else { return Disposable() }

            var movieEndpoint: MovieApiEndpoint

            switch searchCriteria {
            case .nowPlaying:
                movieEndpoint = .moviesNowPlaying(page: page)
            case .topRated:
                movieEndpoint = .moviesTopRated(page: page)
            case .upcomming:
                movieEndpoint = .moviesUpcoming(page: page)
            case .popular:
                movieEndpoint = .moviesPopular(page: page)
            case .discover(let genre):
                movieEndpoint = .discover(genre: genre.id ?? 12, page: page)
            }

			self.networkManager.request (movieEndpoint, completion: { [weak self] data, response, error in
				guard let `self` = self else { return }

				if error != nil {
					let errorDescription = error?.localizedDescription ?? ""
					print("🔴 [Networking] [MovieNetworkService] [moviesApi] An error occurred: \(errorDescription)")
					promise.onError(NetworkResponseApi.failed(errorDescription))
					promise.onComplete()
				}

				if let response = response as? HTTPURLResponse {
					let result = self.networkManager.handleNetworkResponse(response)
					switch result {
						case .success:
							guard let responseData = data else {
								promise.onError(NetworkResponseApi.noData)
								promise.onComplete()
								return
							}
							do {
                                let apiResponse = try JSONDecoder().decode(MoviesApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
								promise.onComplete()

							} catch let exception {
								print("🔴 [Networking] [MovieNetworkService] [moviesApi] An error occurred: \(exception.localizedDescription)")
								promise.onError(NetworkResponseApi.unableToDecode)
								promise.onComplete()
							}
						case .failure(let networkFailureError):
							print("🔴 [Networking] [MovieNetworkService] [moviesApi] An error occurred: \(networkFailureError)")
							promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
							promise.onComplete()
					}
				}
			})
			return Disposable()
		}
	}

    public func movieDetailsApi(movieId: String) -> AnyPublisher<MovieApiResponse, NetworkResponseApi> {
        return AnyPublisher<MovieApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.movieDetails(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [movieDetailsApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [movieDetailsApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [movieDetailsApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }

    public func movieImagesApi(movieId: String) -> AnyPublisher<ImagesApiResponse, NetworkResponseApi> {
        return AnyPublisher<ImagesApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.movieImages(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [movieImagesApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(ImagesApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [movieImagesApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [movieImagesApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }

    public func movieExternalIdsApi(movieId: String) -> AnyPublisher<SocialNetworksApiResponse, NetworkResponseApi> {
        return AnyPublisher<SocialNetworksApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.movieExternalIds(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [movieExternalIdsApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(SocialNetworksApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [movieExternalIdsApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [movieExternalIdsApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }

    public func movieVideosApi(movieId: String) -> AnyPublisher<VideosApiResponse, NetworkResponseApi> {
        return AnyPublisher<VideosApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.movieVideos(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [movieVideosApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(VideosApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [movieVideosApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [movieVideosApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }

    public func movieCreditsApi(movieId: String) -> AnyPublisher<CreditsApiResponse, NetworkResponseApi> {
        return AnyPublisher<CreditsApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.movieCredits(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [movieCreditsApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(CreditsApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [movieCreditsApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [movieCreditsApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }

    public func movieSimilarMoviesApi(movieId: String, page: Int? = nil) -> AnyPublisher<MoviesApiResponse, NetworkResponseApi> {
        return AnyPublisher<MoviesApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.movieSimilarMovies(movieId: movieId, page: page ?? 1), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [movieSimilarMoviesApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(MoviesApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [movieSimilarMoviesApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [movieSimilarMoviesApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }

    public func genresListApi() -> AnyPublisher<GenresApiResponse, NetworkResponseApi> {
        return AnyPublisher<GenresApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.genreList, completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [genresListApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(GenresApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [genresListApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [genresListApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }

    public func searchMovieApi(query: String, page: Int) -> AnyPublisher<MoviesApiResponse, NetworkResponseApi> {
        return AnyPublisher<MoviesApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.searchMovie(query: query, page: page), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [searchMovieApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(MoviesApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [searchMovieApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [searchMovieApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }

    public func discoverApi(genre: Int, page: Int) -> AnyPublisher<MoviesApiResponse, NetworkResponseApi> {
        return AnyPublisher<MoviesApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.discover(genre: genre, page: page), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [discoverApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(MoviesApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [discoverApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [discoverApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }

    // MARK: - Persons
    public func personDetailsApi(personId: String) -> AnyPublisher<PersonApiResponse, NetworkResponseApi> {
        return AnyPublisher<PersonApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.person(personId: personId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [personDetailsApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(PersonApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [personDetailsApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [personDetailsApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }

    public func personMovieCreditsApi(personId: String) -> AnyPublisher<PersonInMovieApiResponse, NetworkResponseApi> {
        return AnyPublisher<PersonInMovieApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.personMovieCredits(personId: personId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [personMovieCreditsApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(PersonInMovieApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [personMovieCreditsApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [personMovieCreditsApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }

    public func personExternalIdsApi(personId: String) -> AnyPublisher<SocialNetworksApiResponse, NetworkResponseApi> {
        return AnyPublisher<SocialNetworksApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.personExternalIds(personId: personId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [personExternalIdsApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(SocialNetworksApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [personExternalIdsApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [personExternalIdsApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }

    public func personImagesApi(personId: String) -> AnyPublisher<PersonImagesApiResponse, NetworkResponseApi> {
        return AnyPublisher<PersonImagesApiResponse, NetworkResponseApi>.create { [weak self] promise in
            guard let `self` = self else { return Disposable() }

            self.networkManager.request(.personImages(personId: personId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [Networking] [MovieNetworkService] [personImagesApi] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponseApi.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponseApi.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(PersonImagesApiResponse.self, from: responseData)

                                promise.onNext(apiResponse)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [Networking] [MovieNetworkService] [personImagesApi] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponseApi.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [Networking] [MovieNetworkService] [personImagesApi] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponseApi.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable()
        }
    }
}
