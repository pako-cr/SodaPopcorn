//
//  ImageApiEndpoint.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Foundation

public enum ImageApiEndpoint {
	case image((imagePath: String, imageSize: String))
}

extension ImageApiEndpoint: EndPointType {
	private var environmentBaseURL: String {
		do {
			let environment = try PlistReaderManager.shared.read(fromOptionName: "Environment") as? String
			return try PlistReaderManager.shared.read(fromContainer: ConfigKeys.imageBaseUrl.rawValue, with: environment ?? "staging") as? String ?? ""

		} catch let error {
			print("❌ [Networking] [ImageApiEndpoint] Error reading base url from configuration file. Error description: \(error)")
			return ""
		}
	}

	var baseURL: URL {
		guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
		return url
	}

	var locale: String {
		return NSLocale.current.languageCode ?? "en"
	}

	var cachePolicy: URLRequest.CachePolicy {
		return .reloadIgnoringLocalAndRemoteCacheData
	}

	var path: String {
		switch self {
			case .image(let imageRequestData):
				return "\(imageRequestData.imageSize)\(imageRequestData.imagePath )"
		}
	}

	var httpMethod: HTTPMethod {
		return .get
	}

	var task: HTTPTask {
		switch self {
			case .image:
				return .requestParameters(bodyParameters: nil,
										  bodyEncoding: .urlEncoding,
										  urlParameters: ["api_key": publicApiKey,
														  "language": locale])
		}
	}

	var headers: HTTPHeaders? {
		return nil
	}
}
