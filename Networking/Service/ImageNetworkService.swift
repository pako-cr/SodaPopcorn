//
//  ImageNetworkService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Foundation

public protocol ImageNetworkServiceProtocol {
    func getImageApi(imagePath: String, imageSize: ImageSizeApi, completion: @escaping (_ imageData: Data?, _ error: NetworkResponseApi?) -> Void)
    func getVideoThumbnailApi(videoUrl: String, completion: @escaping(_ imageData: Data?, _ error: NetworkResponseApi?) -> Void)
}

public final class ImageNetworkService: ImageNetworkServiceProtocol {
	private let networkManager = NetworkManager<ImageApiEndpoint>()

    public init() {
        
    }

	public func getImageApi(imagePath: String, imageSize: ImageSizeApi, completion: @escaping (_ imageData: Data?, _ error: NetworkResponseApi?) -> Void) {
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
				completion(nil, NetworkResponseApi.failed(errorMessage))
			}

			if let response = response as? HTTPURLResponse {
				let result = self.networkManager.handleNetworkResponse(response)
				switch result {
					case .success:
						guard let responseData = data else {
							completion(nil, NetworkResponseApi.noData)
							return
						}
						completion(responseData, nil)
					case .failure(let networkFailureError):
						print("🔴 [ImageNetworkService] [getImageApi] An error occurred: \(networkFailureError)")
						completion(nil, NetworkResponseApi.failed(networkFailureError.localizedDescription))
				}
			}
        }
	}

    public func getVideoThumbnailApi(videoUrl: String, completion: @escaping(_ imageData: Data?, _ error: NetworkResponseApi?) -> Void) {
        networkManager.request(.videoThumbnail(videoUrl: videoUrl)) { [weak self] data, response, error in
            guard let `self` = self else { return }

            if error != nil {
                let errorMessage = error?.localizedDescription ?? ""
                print("🔴 [ImageNetworkService] [getVideoThumbnail] An error occurred: \(errorMessage)")
                completion(nil, NetworkResponseApi.failed(errorMessage))
            }

            if let response = response as? HTTPURLResponse {
                let result = self.networkManager.handleNetworkResponse(response)
                switch result {
                    case .success:
                        guard let responseData = data else {
                            completion(nil, NetworkResponseApi.noData)
                            return
                        }
                        completion(responseData, nil)

                    case .failure(let networkFailureError):
                        print("🔴 [ImageNetworkService] [getVideoThumbnail] An error occurred: \(networkFailureError)")
                        completion(nil, NetworkResponseApi.failed(networkFailureError.localizedDescription))
                }
            }
        }
    }
}
