//
//  ImageNetworkService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Foundation

public protocol ImageNetworkServiceProtocol {
    func getImage(imagePath: String, imageSize: ImageSize, completion: @escaping (_ imageData: Data?, _ error: NetworkResponse?) -> Void)
    func getVideoThumbnail(videoUrl: String, completion: @escaping(_ imageData: Data?, _ error: NetworkResponse?) -> Void)
}

final class ImageNetworkService: ImageNetworkServiceProtocol {
	private let networkManager = NetworkManager<ImageApiEndpoint>()

	func getImage(imagePath: String, imageSize: ImageSize, completion: @escaping (_ imageData: Data?, _ error: NetworkResponse?) -> Void) {
        var imageSizeRaw: String

        switch imageSize {
        case .poster(let size):
            imageSizeRaw = size.rawValue
        case .backdrop(let size):
            imageSizeRaw = size.rawValue
        case .logo(let size):
            imageSizeRaw = size.rawValue
        case .profile(let size):
            imageSizeRaw = size.rawValue
        }

        networkManager.request(.image((imagePath: imagePath, imageSize: imageSizeRaw))) { [weak self] data, response, error in
			guard let `self` = self else { return }

			if error != nil {
				let errorMessage = error?.localizedDescription ?? ""
				print("🔴 [ImageNetworkService] [getImage] An error occurred: \(errorMessage)")
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
						print("🔴 [ImageNetworkService] [getImage] An error occurred: \(networkFailureError)")
						completion(nil, NetworkResponse.failed(networkFailureError.localizedDescription))
				}
			}
		}
	}

    func getVideoThumbnail(videoUrl: String, completion: @escaping(_ imageData: Data?, _ error: NetworkResponse?) -> Void) {
        networkManager.request(.videoThumbnail(videoUrl: videoUrl)) { [weak self] data, response, error in
            guard let `self` = self else { return }

            if error != nil {
                let errorMessage = error?.localizedDescription ?? ""
                print("🔴 [ImageNetworkService] [getVideoThumbnail] An error occurred: \(errorMessage)")
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
                        print("🔴 [ImageNetworkService] [getVideoThumbnail] An error occurred: \(networkFailureError)")
                        completion(nil, NetworkResponse.failed(networkFailureError.localizedDescription))
                }
            }
        }
    }
}
