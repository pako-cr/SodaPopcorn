//
//  MovieEndpoint.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/9/21.
//

import Foundation

public enum MovieApi {
	case newMovies(page: Int)
	case video(id: Int)
    case details(movieId: String)
    case images(movieId: String)
    case socialNetworks(movieId: String)
}

// Example url: https://api.themoviedb.org/3/movie/550?page=1&api_key=ae3f83170dac3764098efb70c9dd7cdf
extension MovieApi: EndPointType {
	private var environmentBaseURL: String {
		do {
			let environment = try PlistReaderManager.shared.read(fromOptionName: "Environment") as? String
			return try PlistReaderManager.shared.read(fromContainer: ConfigKeys.baseUrl.rawValue, with: environment ?? "staging") as? String ?? ""

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
        case .newMovies:
            return "now_playing"
        case .video(let id):
            return "\(id)/videos"
        case .details(let movieId):
            return "\(movieId)"
        case .images(let movieId):
            return "\(movieId)/images"
        case .socialNetworks(let movieId):
            return "\(movieId)/external_ids"
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
                                                      "api_key": publicApiKey,
                                                      "language": locale])
        case .details:
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: ["api_key": publicApiKey,
                                                      "language": locale])
        case .images:
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: ["api_key": publicApiKey,
                                                      "language": locale])
        case .socialNetworks:
                    return .requestParameters(bodyParameters: nil,
                                              bodyEncoding: .urlEncoding,
                                              urlParameters: ["api_key": publicApiKey,
                                                              "language": locale])
        default:
            return .request
        }
    }

	var headers: HTTPHeaders? {
		return nil
	}
}
