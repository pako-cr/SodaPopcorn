//
//  PosterImageService.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 4/9/21.
//

import Foundation

public protocol PosterImageServiceProtocol {
	func getPosterImage(posterPath: String, completion: @escaping (_ imageData: Data?, _ error: String?) -> Void)
}

final class PosterImageService: PosterImageServiceProtocol {
	private let networkManager: NetworkManager<PosterImageApi>

	private static let sharedPosterImageService: PosterImageService = {
		return PosterImageService()
	}()

	private init() {
		self.networkManager = NetworkManager<PosterImageApi>()
	}

	static func shared() -> PosterImageService {
		return sharedPosterImageService
	}

	func getPosterImage(posterPath: String, completion: @escaping (_ imageData: Data?, _ error: String?) -> Void) {
		networkManager.request(.posterImage(posterPath: posterPath)) { [weak self] data, response, error in
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
						completion(responseData, nil)
					case .failure(let networkFailureError):
						completion(nil, networkFailureError)
				}
			}
		}
	}
}
