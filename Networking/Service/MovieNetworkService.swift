//
//  MovieNetworkService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Combine
import Foundation

public protocol MovieNetworkServiceProtocol {
	func getNewMovies(page: Int) -> AnyPublisher<MovieApiResponse, NetworkResponse>
}

final class MovieNetworkService: MovieNetworkServiceProtocol {
	private let networkManager = NetworkManager<MovieApi>()
	
	func getNewMovies(page: Int) -> AnyPublisher<MovieApiResponse, NetworkResponse> {
		return AnyPublisher<MovieApiResponse, NetworkResponse>.create { [weak self] promise in
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
								let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)

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
}
