//
//  MovieService.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 4/9/21.
//

import Foundation

public protocol MovieServiceProtocol {
	func getNewMovies(page: Int, completion: @escaping (_ movies: [Movie]?, _ error: String?) -> Void)
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

	func getNewMovies(page: Int, completion: @escaping (_ movies: [Movie]?, _ error: String?) -> Void) {
		networkManager.request(.newMovies(page: page)) { [weak self] data, response, error in
			guard let `self` = self else { return }

			if error != nil {
				completion(nil, "Please check your network connection.")
			}

			if let response = response as? HTTPURLResponse {
				let result = self.networkManager.handleNetworkResponse(response)
				switch result {
					case .success:
						guard let responseData = data else {
							completion(nil, NetworkResponse.noData.rawValue)
							return
						}
						do {
//							let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
//							print("🔸 [MovieService] [getMovies] Json data: \n\(jsonData)")
							let apiResponse = try JSONDecoder().decode(MovieApiResponse.self, from: responseData)
							completion(apiResponse.movies, nil)

						} catch {
							print("🔴 [MovieService] [getMovies] An error occurred: \(error)")
							completion(nil, NetworkResponse.unableToDecode.rawValue)
						}
					case .failure(let networkFailureError):
						completion(nil, networkFailureError)
				}
			}
		}
	}
}
