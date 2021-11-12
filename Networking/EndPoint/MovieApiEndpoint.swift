//
//  MovieApiEndpoint.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/9/21.
//

import Foundation

public enum MovieApiEndpoint {
    case moviesNowPlaying(page: Int)
	case movieVideos(movieId: String)
    case movieDetails(movieId: String)
    case movieImages(movieId: String)
    case movieExternalIds(movieId: String)
    case movieCredits(movieId: String)
    case person(personId: String)
    case personMovieCredits(personId: String)
    case personExternalIds(personId: String)
}

extension MovieApiEndpoint: EndPointType {
	private var environmentBaseURL: String {
		do {
			let environment = try PlistReaderManager.shared.read(fromOptionName: "Environment") as? String

            var base = try PlistReaderManager.shared.read(fromContainer: ConfigKeys.baseUrl.rawValue, with: environment ?? "staging") as? String ?? ""

            switch self {
            case .person, .personMovieCredits, .personExternalIds:
                base.append(contentsOf: "person")
                break
            default:
                base.append(contentsOf: "movie")
                break
            }

			return base

		} catch let error {
			print("❌ [Networking] [MovieApiEndpoint] Error reading base url from configuration file. Error description: \(error)")
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
        case .moviesNowPlaying:
            return "now_playing"
        case .movieVideos(let movieId):
            return "\(movieId)/videos"
        case .movieDetails(let movieId):
            return "\(movieId)"
        case .movieImages(let movieId):
            return "\(movieId)/images"
        case .movieExternalIds(let movieId):
            return "\(movieId)/external_ids"
        case .movieCredits(let movieId):
            return "\(movieId)/credits"
        case .person(let personId):
            return "\(personId)"
        case .personMovieCredits(let personId):
            return "\(personId)/movie_credits"
        case .personExternalIds(let personId):
            return "\(personId)/external_ids"
        }
    }

    var httpMethod: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .moviesNowPlaying(let page):
            return .requestParameters(bodyParameters: nil,
                                      bodyEncoding: .urlEncoding,
                                      urlParameters: ["page": page,
                                                      "api_key": publicApiKey,
                                                      "language": locale])
        case .movieDetails, .movieImages, .movieExternalIds, .movieVideos, .movieCredits, .person, .personMovieCredits, .personExternalIds:
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
