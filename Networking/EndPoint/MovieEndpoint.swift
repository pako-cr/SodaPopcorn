//
//  MovieEndpoint.swift
//  StarWarsWorld
//
//  Created by Zimplifica Macbook Pro on 3/9/21.
//

import Foundation

public enum MovieApi {
	case recommended(id: Int)
	case popular(page: Int)
	case newMovies(page: Int)
	case video(id: Int)
}

// Example url: https://api.themoviedb.org/3/movie/550?page=1&api_key=ae3f83170dac3764098efb70c9dd7cdf
extension MovieApi: EndPointType {
	private var environmentBaseURL: String {
		switch environment {
			case .production: return "https://api.themoviedb.org/3/movie/"
			case .staging: return "https://staging.themoviedb.org/3/movie/"
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
			case .recommended(let id):
				return "\(id)/recommendations"
			case .popular:
				return "popular"
			case .newMovies:
				return "now_playing"
			case .video(let id):
				return "\(id)/videos"
		}
	}

	var httpMethod: HTTPMethod {
		return .get
	}

	var task: HTTPTask {
		switch self {
			case .newMovies(let page):
				return .requestParameters(bodyParameters: nil,
										  bodyEncoding: .urlEncoding,
										  urlParameters: ["page": page,
														  "api_key": publicApiKey])
			default:
				return .request
		}
	}

	var headers: HTTPHeaders? {
		return nil
	}
}
