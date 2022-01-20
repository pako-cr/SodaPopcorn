//
//  ImageService.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

import Foundation
import Networking

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

    /// Use this method to get images
    /// - Parameters:
    ///   - imagePath: The image path
    ///   - imageSize: The image size
    ///   - completion: The callback
    public func getImage(imagePath: String, imageSize: ImageSize, completion: @escaping (Data?, NetworkResponse?) -> Void) {
        var imageSizeApi: ImageSizeApi

        switch imageSize {
        case .poster(let size):
            var posterSizeApi: PosterSizeApi

            switch size {
            case .w92:  posterSizeApi = .w92
            case .w154: posterSizeApi = .w154
            case .w185: posterSizeApi = .w185
            case .w342: posterSizeApi = .w342
            case .w500: posterSizeApi = .w500
            case .w780: posterSizeApi = .w780
            case .original: posterSizeApi = .original
            }

            imageSizeApi = .poster(size: posterSizeApi)
        case .backdrop(let size):
            var backdropSizeApi: BackdropSizeApi

            switch size {
            case .w300: backdropSizeApi = .w300
            case .w780: backdropSizeApi = .w780
            case .w1280: backdropSizeApi = .w1280
            case .original: backdropSizeApi = .original
            }

            imageSizeApi = .backdrop(size: backdropSizeApi)
        case .logo(let size):
            var logoSizeApi: LogoSizeApi

            switch size {
            case .w45: logoSizeApi = .w45
            case .w92: logoSizeApi = .w92
            case .w154: logoSizeApi = .w154
            case .w185: logoSizeApi = .w185
            case .w300: logoSizeApi = .w300
            case .w500: logoSizeApi = .w500
            case .original: logoSizeApi = .original
            }

            imageSizeApi = .logo(size: logoSizeApi)
        case .profile(let size):
            var profileSizeApi: ProfileSizeApi

            switch size {
            case .w45: profileSizeApi = .w45
            case .w185: profileSizeApi = .w185
            case .h632: profileSizeApi = .h632
            case .original: profileSizeApi = .original
            }

            imageSizeApi = .profile(size: profileSizeApi)
        }

        self.getImageApi(imagePath: imagePath, imageSize: imageSizeApi) { data, networkResponseApi in
            var networkResponse: NetworkResponse
            switch networkResponseApi {
            case .success(let msg): networkResponse = .success(msg)
            case .authenticationError: networkResponse = .authenticationError
            case .badRequest: networkResponse = .badRequest
            case .outdated: networkResponse = .outdated
            case .failed(let error): networkResponse = .failed(error)
            case .noData: networkResponse = .noData
            case .unableToDecode: networkResponse = .unableToDecode
            case .none: networkResponse = .noData
            }

            completion(data, networkResponse)
        }
    }

    /// Use this method to get a video's thumbnail
    /// - Parameters:
    ///   - videoUrl: The video url.
    ///   - completion: The callback.
    public func getVideoThumbnail(videoUrl: String, completion: @escaping(_ imageData: Data?, _ error: NetworkResponse?) -> Void) {
        self.getVideoThumbnailApi(videoUrl: videoUrl) { imageData, networkResponseApi in
            var networkResponse: NetworkResponse
            switch networkResponseApi {
            case .success(let msg): networkResponse = .success(msg)
            case .authenticationError: networkResponse = .authenticationError
            case .badRequest: networkResponse = .badRequest
            case .outdated: networkResponse = .outdated
            case .failed(let error): networkResponse = .failed(error)
            case .noData: networkResponse = .noData
            case .unableToDecode: networkResponse = .unableToDecode
            case .none: networkResponse = .noData
            }

            completion(imageData, networkResponse)
        }
    }

    // MARK: - Network Service
    public func getImageApi(imagePath: String, imageSize: ImageSizeApi, completion: @escaping (Data?, NetworkResponseApi?) -> Void) {
        return imageNetworkService.getImageApi(imagePath: imagePath, imageSize: imageSize, completion: completion)
    }

    public func getVideoThumbnailApi(videoUrl: String, completion: @escaping(_ imageData: Data?, _ error: NetworkResponseApi?) -> Void) {
        return imageNetworkService.getVideoThumbnailApi(videoUrl: videoUrl, completion: completion)
    }
}
