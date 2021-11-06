//
//  MovieNetworkService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Combine
import Foundation

public protocol MovieNetworkServiceProtocol {
	func getNewMovies(page: Int) -> AnyPublisher<MoviesApiResponse, NetworkResponse>
    func movieDetails(movieId: String) -> AnyPublisher<Movie, NetworkResponse>
    func getImages(movieId: String) -> AnyPublisher<ImagesApiResponse, NetworkResponse>
}

final class MovieNetworkService: MovieNetworkServiceProtocol {
	private let networkManager = NetworkManager<MovieApi>()
	
	func getNewMovies(page: Int) -> AnyPublisher<MoviesApiResponse, NetworkResponse> {
		return AnyPublisher<MoviesApiResponse, NetworkResponse>.create { [weak self] promise in
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

								promise.onNext(apiResponse)
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
                                let apiResponse = try JSONDecoder().decode(Movie.self, from: responseData)

                                promise.onNext(apiResponse)
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

    func getImages(movieId: String) -> AnyPublisher<ImagesApiResponse, NetworkResponse> {
        return AnyPublisher<ImagesApiResponse, NetworkResponse>.create { [weak self] promise in
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

                                promise.onNext(apiResponse)
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
}
