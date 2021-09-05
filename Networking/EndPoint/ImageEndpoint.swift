//
//  PosterImageEndpoint.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 4/9/21.
//

import Foundation

public enum PosterImageApi {
	case posterImage(posterPath: String)
}

// Example image url: https://image.tmdb.org/t/p/w500/iXbWpCkIauBMStSTUT9v4GXvdgH.jpg
extension PosterImageApi: EndPointType {
	private var environmentBaseURL: String {
		switch environment {
			case .production: return "https://image.tmdb.org/t/p/w92"
			case .staging: return "https://image.tmdb.org/t/p/w92"
		}
	}

	var baseURL: URL {
		guard let url = URL(string: environmentBaseURL) else { fatalError("baseURL could not be configured.")}
		return url
	}

	var cachePolicy: URLRequest.CachePolicy {
		return .reloadIgnoringLocalAndRemoteCacheData
	}

	var path: String {
		switch self {
			case .posterImage(let posterPath):
				return posterPath
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
										  urlParameters: [ "api_key": publicApiKey])
		}
	}

	var headers: HTTPHeaders? {
		return nil
	}
}
