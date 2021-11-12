//
//  MovieNetworkService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Combine
import Foundation

public protocol MovieNetworkServiceProtocol {
	func moviesNowPlaying(page: Int) -> AnyPublisher<Movies, NetworkResponse>
    func movieDetails(movieId: String) -> AnyPublisher<Movie, NetworkResponse>
    func movieImages(movieId: String) -> AnyPublisher<MovieImages, NetworkResponse>
    func movieExternalIds(movieId: String) -> AnyPublisher<SocialNetworks, NetworkResponse>
    func movieVideos(movieId: String) -> AnyPublisher<Videos, NetworkResponse>
    func movieCredits(movieId: String) -> AnyPublisher<Credits, NetworkResponse>
    func personDetails(personId: String) -> AnyPublisher<Person, NetworkResponse>
    func personMovieCredits(personId: String) -> AnyPublisher<[Movie], NetworkResponse>
    func personExternalIds(personId: String) -> AnyPublisher<SocialNetworks, NetworkResponse>
}

final class MovieNetworkService: MovieNetworkServiceProtocol {
	private let networkManager = NetworkManager<MovieApiEndpoint>()
	
	func moviesNowPlaying(page: Int) -> AnyPublisher<Movies, NetworkResponse> {
		return AnyPublisher<Movies, NetworkResponse>.create { [weak self] promise in
			guard let `self` = self else { return Disposable {} }

			self.networkManager.request(.moviesNowPlaying(page: page), completion: { [weak self] data, response, error in
				guard let `self` = self else { return }

				if error != nil {
					let errorDescription = error?.localizedDescription ?? ""
					print("🔴 [MovieNetworkService] [moviesNowPlaying] An error occurred: \(errorDescription)")
					promise.onError(NetworkResponse.failed(errorDescription))
					promise.onComplete()
				}

				if let response = response as? HTTPURLResponse {
					let result = self.networkManager.handleNetworkResponse(response)
					switch result {
						case .success:
							guard let responseData = data else {
								promise.onError(NetworkResponse.noData)
								promise.onComplete()
								return
							}
							do {
								let apiResponse = try JSONDecoder().decode(MoviesApiResponse.self, from: responseData)

                                let response = Movies(apiResponse: apiResponse)

                                promise.onNext(response)
								promise.onComplete()

							} catch let exception {
								print("🔴 [MovieNetworkService] [moviesNowPlaying] An error occurred: \(exception.localizedDescription)")
								promise.onError(NetworkResponse.unableToDecode)
								promise.onComplete()
							}
						case .failure(let networkFailureError):
							print("🔴 [MovieNetworkService] [moviesNowPlaying] An error occurred: \(networkFailureError)")
							promise.onError(NetworkResponse.failed(networkFailureError.localizedDescription))
							promise.onComplete()
					}
				}
			})
			return Disposable {}
		}
	}
    
    func movieDetails(movieId: String) -> AnyPublisher<Movie, NetworkResponse> {
        return AnyPublisher<Movie, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable {} }

            self.networkManager.request(.movieDetails(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [MovieNetworkService] [movieDetails] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponse.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponse.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)

                                let response = Movie(apiResponse: apiResponse)

                                promise.onNext(response)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [MovieNetworkService] [movieDetails] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponse.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [MovieNetworkService] [movieDetails] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponse.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable {}
        }
    }

    func movieImages(movieId: String) -> AnyPublisher<MovieImages, NetworkResponse> {
        return AnyPublisher<MovieImages, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable {} }

            self.networkManager.request(.movieImages(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [MovieNetworkService] [movieImages] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponse.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponse.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(ImagesApiResponse.self, from: responseData)

                                let response = MovieImages(apiResponse: apiResponse)

                                promise.onNext(response)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [MovieNetworkService] [movieImages] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponse.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [MovieNetworkService] [movieImages] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponse.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable {}
        }
    }

    func movieExternalIds(movieId: String) -> AnyPublisher<SocialNetworks, NetworkResponse> {
        return AnyPublisher<SocialNetworks, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable {} }

            self.networkManager.request(.movieExternalIds(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [MovieNetworkService] [movieExternalIds] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponse.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponse.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(SocialNetworksApiResponse.self, from: responseData)

                                let response = SocialNetworks(apiResponse: apiResponse)

                                promise.onNext(response)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [MovieNetworkService] [movieExternalIds] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponse.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [MovieNetworkService] [movieExternalIds] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponse.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable {}
        }
    }

    func movieVideos(movieId: String) -> AnyPublisher<Videos, NetworkResponse> {
        return AnyPublisher<Videos, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable {} }

            self.networkManager.request(.movieVideos(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [MovieNetworkService] [movieVideos] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponse.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponse.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(VideosApiResponse.self, from: responseData)

                                let response = Videos(apiResponse: apiResponse)

                                promise.onNext(response)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [MovieNetworkService] [movieVideos] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponse.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [MovieNetworkService] [movieVideos] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponse.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable {}
        }
    }

    func movieCredits(movieId: String) -> AnyPublisher<Credits, NetworkResponse> {
        return AnyPublisher<Credits, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable {} }

            self.networkManager.request(.movieCredits(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [MovieNetworkService] [movieCredits] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponse.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponse.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(CreditsApiResponse.self, from: responseData)

                                let response = Credits(apiResponse: apiResponse)

                                promise.onNext(response)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [MovieNetworkService] [movieCredits] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponse.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [MovieNetworkService] [movieCredits] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponse.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable {}
        }
    }

    func personDetails(personId: String) -> AnyPublisher<Person, NetworkResponse> {
        return AnyPublisher<Person, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable {} }

            self.networkManager.request(.person(personId: personId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [MovieNetworkService] [person] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponse.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponse.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(PersonApiResponse.self, from: responseData)

                                let response = Person(apiResponse: apiResponse)

                                promise.onNext(response)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [MovieNetworkService] [personDetails] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponse.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [MovieNetworkService] [personDetails] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponse.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable {}
        }
    }

    func personMovieCredits(personId: String) -> AnyPublisher<[Movie], NetworkResponse> {
        return AnyPublisher<[Movie], NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable {} }

            self.networkManager.request(.personMovieCredits(personId: personId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [MovieNetworkService] [personMovieCredits] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponse.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponse.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(PersonInMovieApiResponse.self, from: responseData)

                                let response = PersonInMovie(apiResponse: apiResponse)

                                if let movies = response.cast {
                                    promise.onNext(movies)
                                }
                                
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [MovieNetworkService] [personMovieCredits] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponse.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [MovieNetworkService] [personMovieCredits] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponse.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable {}
        }
    }

    func personExternalIds(personId: String) -> AnyPublisher<SocialNetworks, NetworkResponse> {
        return AnyPublisher<SocialNetworks, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable {} }

            self.networkManager.request(.personExternalIds(personId: personId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [MovieNetworkService] [personExternalIds] An error occurred: \(errorDescription)")
                    promise.onError(NetworkResponse.failed(errorDescription))
                    promise.onComplete()
                }

                if let response = response as? HTTPURLResponse {
                    let result = self.networkManager.handleNetworkResponse(response)
                    switch result {
                        case .success:
                            guard let responseData = data else {
                                promise.onError(NetworkResponse.noData)
                                promise.onComplete()
                                return
                            }
                            do {
                                let apiResponse = try JSONDecoder().decode(SocialNetworksApiResponse.self, from: responseData)

                                let response = SocialNetworks(apiResponse: apiResponse)

                                promise.onNext(response)
                                promise.onComplete()

                            } catch let exception {
                                print("🔴 [MovieNetworkService] [personExternalIds] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponse.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [MovieNetworkService] [personExternalIds] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponse.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable {}
        }
    }
}
