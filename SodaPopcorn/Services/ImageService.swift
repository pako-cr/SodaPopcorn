//
//  ImageService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

import Foundation

public final class ImageService: ImageNetworkServiceProtocol {
    private let imageNetworkService: ImageNetworkService

    private static let sharedImageService: ImageService = {
        return ImageService(imageNetworkService: ImageNetworkService())
    }()

    private init(imageNetworkService: ImageNetworkService) {
        self.imageNetworkService = imageNetworkService
    }

    static func shared() -> ImageService {
        return sharedImageService
    }

    // MARK: - Network Service
    public func getImage(imagePath: String, imageSize: ImageSize, completion: @escaping (Data?, NetworkResponse?) -> Void) {
        return imageNetworkService.getImage(imagePath: imagePath, imageSize: imageSize, completion: completion)
    }
}
