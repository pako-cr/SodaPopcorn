//
//  MovieNetworkService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Combine
import Foundation

public protocol MovieNetworkServiceProtocol {
	func getNewMovies(page: Int) -> AnyPublisher<Movies, NetworkResponse>
    func movieDetails(movieId: String) -> AnyPublisher<Movie, NetworkResponse>
    func getImages(movieId: String) -> AnyPublisher<MovieImages, NetworkResponse>
    func socialNetworks(movieId: String) -> AnyPublisher<SocialNetworks, NetworkResponse>
    func getVideos(movieId: String) -> AnyPublisher<Videos, NetworkResponse>
    func movieCredits(movieId: String) -> AnyPublisher<Credits, NetworkResponse>
    func personDetails(personId: String) -> AnyPublisher<Person, NetworkResponse>
}

final class MovieNetworkService: MovieNetworkServiceProtocol {
	private let networkManager = NetworkManager<MovieApiEndpoint>()
	
	func getNewMovies(page: Int) -> AnyPublisher<Movies, NetworkResponse> {
		return AnyPublisher<Movies, NetworkResponse>.create { [weak self] promise in
			guard let `self` = self else { return Disposable {} }

			self.networkManager.request(.newMovies(page: page), completion: { [weak self] data, response, error in
				guard let `self` = self else { return }

				if error != nil {
					let errorDescription = error?.localizedDescription ?? ""
					print("🔴 [MovieNetworkService] [getMovies] An error occurred: \(errorDescription)")
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
								print("🔴 [MovieNetworkService] [getMovies] An error occurred: \(exception.localizedDescription)")
								promise.onError(NetworkResponse.unableToDecode)
								promise.onComplete()
							}
						case .failure(let networkFailureError):
							print("🔴 [MovieNetworkService] [getMovies] An error occurred: \(networkFailureError)")
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

            self.networkManager.request(.details(movieId: movieId), completion: { [weak self] data, response, error in
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

    func getImages(movieId: String) -> AnyPublisher<MovieImages, NetworkResponse> {
        return AnyPublisher<MovieImages, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable {} }

            self.networkManager.request(.images(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [MovieNetworkService] [images] An error occurred: \(errorDescription)")
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
                                print("🔴 [MovieNetworkService] [images] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponse.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [MovieNetworkService] [images] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponse.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable {}
        }
    }

    func socialNetworks(movieId: String) -> AnyPublisher<SocialNetworks, NetworkResponse> {
        return AnyPublisher<SocialNetworks, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable {} }

            self.networkManager.request(.socialNetworks(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [MovieNetworkService] [socialNetworks] An error occurred: \(errorDescription)")
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
                                print("🔴 [MovieNetworkService] [socialNetworks] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponse.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [MovieNetworkService] [socialNetworks] An error occurred: \(networkFailureError)")
                            promise.onError(NetworkResponse.failed(networkFailureError.localizedDescription))
                            promise.onComplete()
                    }
                }
            })
            return Disposable {}
        }
    }

    func getVideos(movieId: String) -> AnyPublisher<Videos, NetworkResponse> {
        return AnyPublisher<Videos, NetworkResponse>.create { [weak self] promise in
            guard let `self` = self else { return Disposable {} }

            self.networkManager.request(.videos(movieId: movieId), completion: { [weak self] data, response, error in
                guard let `self` = self else { return }

                if error != nil {
                    let errorDescription = error?.localizedDescription ?? ""
                    print("🔴 [MovieNetworkService] [getVideos] An error occurred: \(errorDescription)")
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
                                print("🔴 [MovieNetworkService] [getVideos] An error occurred: \(exception.localizedDescription)")
                                promise.onError(NetworkResponse.unableToDecode)
                                promise.onComplete()
                            }
                        case .failure(let networkFailureError):
                            print("🔴 [MovieNetworkService] [getVideos] An error occurred: \(networkFailureError)")
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

            self.networkManager.request(.credits(movieId: movieId), completion: { [weak self] data, response, error in
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
                    print("🔴 [MovieNetworkService] [personDetails] An error occurred: \(errorDescription)")
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
}
