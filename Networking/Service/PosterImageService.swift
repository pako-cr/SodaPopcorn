//
//  PosterImageService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Foundation

public protocol PosterImageServiceProtocol {
	func getPosterImage(posterPath: String, posterSize: PosterSize, completion: @escaping (_ imageData: Data?, _ error: NetworkResponse?) -> Void)
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

	func getPosterImage(posterPath: String, posterSize: PosterSize, completion: @escaping (_ imageData: Data?, _ error: NetworkResponse?) -> Void) {
		networkManager.request(.posterImage((posterPath: posterPath, posterSize: posterSize.rawValue))) { [weak self] data, response, error in
			guard let `self` = self else { return }

			if error != nil {
				let errorMessage = error?.localizedDescription ?? ""
				print("🔴 [PosterImageService] [getPosterImage] An error occurred: \(errorMessage)")
				completion(nil, NetworkResponse.failed(errorMessage))
			}

			if let response = response as? HTTPURLResponse {
				let result = self.networkManager.handleNetworkResponse(response)
				switch result {
					case .success:
						guard let responseData = data else {
							completion(nil, NetworkResponse.noData)
							return
						}
						completion(responseData, nil)
					case .failure(let networkFailureError):
						print("🔴 [PosterImageService] [getPosterImage] An error occurred: \(networkFailureError)")
						completion(nil, NetworkResponse.failed(networkFailureError.localizedDescription))
				}
			}
		}
	}
}
