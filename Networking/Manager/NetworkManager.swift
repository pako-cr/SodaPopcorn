//
//  NetworkingManager.swift
//  StarWarsWorld
//
//  Created by Francisco Cordoba on 3/9/21.
//

import Foundation

public typealias NetworkManagerCompletion = (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void

protocol NetworkManagerProtocol: AnyObject {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completion: @escaping NetworkManagerCompletion)
    func cancel()
}

final class NetworkManager<EndPoint: EndPointType>: NetworkManagerProtocol {

    private var task: URLSessionTask?

    func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String> {
        switch response.statusCode {
            case 200...299: return .success(response.description)
            case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
            case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
            case 600: return .failure(NetworkResponse.outdated.rawValue)
            default: return .failure(NetworkResponse.failed.rawValue)
        }
    }

    func request(_ route: EndPoint, completion: @escaping NetworkManagerCompletion) {
        do {
            let request = try self.buildRequest(from: route)

			if route is MovieApi {
				print("🔸 Request: \(request)")
			}

			task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                completion(data, response, error)
            })
        } catch {
            completion(nil, nil, error)
        }

        self.task?.resume()
    }

    func cancel() {
        self.task?.cancel()
    }

    private func buildRequest(from route: EndPoint) throws -> URLRequest {
		var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path), cachePolicy: route.cachePolicy, timeoutInterval: 10.0)

        request.httpMethod = route.httpMethod.rawValue

        do {
            switch route.task {
                case .request:
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                case .requestParameters(let bodyParameters, let bodyEncoding, let urlParameters):
                    try self.configureParameters(bodyParameters: bodyParameters, bodyEncoding: bodyEncoding, urlParameters: urlParameters, request: &request)

                case .requestParametersAndHeaders(let bodyParameters, let bodyEncoding, let urlParameters, let additionHeaders):
                    self.addAdditionalHeaders(additionHeaders, request: &request)
                    try self.configureParameters(bodyParameters: bodyParameters, bodyEncoding: bodyEncoding, urlParameters: urlParameters, request: &request)
            }

            return request

        } catch {
            throw error
        }
    }

	private func configureParameters(bodyParameters: Parameters?, bodyEncoding: ParameterEncoding, urlParameters: Parameters?, request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request, bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }

    private func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
