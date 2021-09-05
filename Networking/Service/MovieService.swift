//
//  MovieService.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 4/9/21.
//

import Combine
import Foundation

public protocol MovieServiceProtocol {
	func getNewMovies(page: Int) -> AnyPublisher<[Movie]?, Error>
}

final class MovieService: MovieServiceProtocol {
	private let networkManager: NetworkManager<MovieApi>

	private static let sharedMovieService: MovieService = {
		return MovieService()
	}()

	private init() {
		self.networkManager = NetworkManager<MovieApi>()
	}

	static func shared() -> MovieService {
		return sharedMovieService
	}

	func getNewMovies(page: Int) -> AnyPublisher<[Movie]?, Error> {
		return AnyPublisher<[Movie]?, Error>.create { [weak self] single in
			guard let `self` = self else { return Disposable {} }

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
								return
							}
							do {
								let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)
								single.onNext(apiResponse.movies)
								single.onComplete()

							} catch let exepction {
								print("🔴 [MovieService] [getMovies] An error occurred: \(exepction.localizedDescription)")
								single.onError(NSError(domain: NetworkResponse.unableToDecode.rawValue, code: 1, userInfo: [:]))
							}
						case .failure(let networkFailureError):
							single.onError(NSError(domain: networkFailureError, code: 1, userInfo: [:]))
					}
				}
			})
			return Disposable {}
		}
	}
}
