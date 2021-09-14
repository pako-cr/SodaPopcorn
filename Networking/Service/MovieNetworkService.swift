//
//  MovieNetworkService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Combine
import Foundation

public protocol MovieNetworkServiceProtocol {
	func getNewMovies(page: Int) -> AnyPublisher<[Movie]?, Error>
}

final class MovieNetworkService: MovieNetworkServiceProtocol {
	private let networkManager: NetworkManager<MovieApi>

	init() {
		self.networkManager = NetworkManager<MovieApi>()
	}
	
	func getNewMovies(page: Int) -> AnyPublisher<[Movie]?, Error> {
		return AnyPublisher<[Movie]?, Error>.create { [weak self] single in
			guard let `self` = self else { return Disposable {} }

			print("🔸 Request getNewMovies. Page: \(page)")

			self.networkManager.request(.newMovies(page: page), completion: { [weak self] data, response, error in
				guard let `self` = self else { return }

				if error != nil {
					single.onError(NSError(domain: "Please check your network connection.", code: 1, userInfo: [:]))
				}

				if let response = response as? HTTPURLResponse {
					let result = self.networkManager.handleNetworkResponse(response)
					switch result {
						case .success:
							guard let responseData = data else {
								single.onError(NSError(domain: NetworkResponse.noData.rawValue, code: 1, userInfo: [:]))
								single.onComplete()
								return
							}
							do {
								let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)

								single.onNext(apiResponse.movies)
								single.onComplete()

							} catch let exepction {
								print("🔴 [MovieNetworkService] [getMovies] An error occurred: \(exepction.localizedDescription)")
								single.onError(NSError(domain: NetworkResponse.unableToDecode.rawValue, code: 1, userInfo: [:]))
								single.onComplete()
							}
						case .failure(let networkFailureError):
							single.onError(NSError(domain: networkFailureError, code: 1, userInfo: [:]))
							single.onComplete()
					}
				}
			})
			return Disposable {}
		}
	}
}
