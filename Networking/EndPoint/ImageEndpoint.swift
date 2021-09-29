//
//  PosterImageEndpoint.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Foundation

public enum PosterImageApi {
	case posterImage((posterPath: String, posterSize: String))
}

// Example image url: https://image.tmdb.org/t/p/w500/iXbWpCkIauBMStSTUT9v4GXvdgH.jpg
extension PosterImageApi: EndPointType {
	private var environmentBaseURL: String {
		do {
			let environment = try PlistReaderManager.shared.read(fromOptionName: "Environment") as? String
			return try PlistReaderManager.shared.read(fromContainer: ConfigKeys.imageBaseUrl.rawValue, with: environment ?? "staging") as? String ?? ""

		} catch let error {
			print("❌ [Networking] [MovieApi] Error reading base url from configuration file. Error description: \(error)")
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
			case .posterImage(let imageRequestData):
				return "\(imageRequestData.posterSize)\(imageRequestData.posterPath )"
		}
	}

	var httpMethod: HTTPMethod {
		return .get
	}

	var task: HTTPTask {
		switch self {
			case .posterImage:
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
