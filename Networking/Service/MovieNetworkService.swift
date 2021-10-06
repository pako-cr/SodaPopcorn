//
//  MovieNetworkService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Combine
import Foundation

public protocol MovieNetworkServiceProtocol {
	func getNewMovies(page: Int) -> AnyPublisher<MovieApiResponse?, Error>
}

final class MovieNetworkService: MovieNetworkServiceProtocol {
	private let networkManager = NetworkManager<MovieApi>()
	
	func getNewMovies(page: Int) -> AnyPublisher<MovieApiResponse?, Error> {
		return AnyPublisher<MovieApiResponse?, Error>.create { [weak self] singles in
			guard let `self` = self else { return Disposable {} }

			self.networkManager.request(.newMovies(page: page), completion: { [weak self] data, response, error in
				guard let `self` = self else { return }

				if error != nil {
					singles.onError(NSError(domain: "Please check your network connection.", code: 1, userInfo: [:]))
				}

				if let response = response as? HTTPURLResponse {
					let result = self.networkManager.handleNetworkResponse(response)
					switch result {
						case .success:
							guard let responseData = data else {
								singles.onError(NSError(domain: NetworkResponse.noData.rawValue, code: 2, userInfo: [:]))
								singles.onComplete()
								return
							}
							do {
								let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)

								singles.onNext(apiResponse)
								singles.onComplete()

							} catch let exception {
								print("🔴 [MovieNetworkService] [getMovies] An error occurred: \(exception.localizedDescription)")
								singles.onError(NSError(domain: NetworkResponse.unableToDecode.rawValue, code: 3, userInfo: [:]))
								singles.onComplete()
							}
						case .failure(let networkFailureError):
							singles.onError(NSError(domain: networkFailureError, code: 1, userInfo: [:]))
							singles.onComplete()
					}
				}
			})
			return Disposable {}
		}
	}
}
