//
//  JSONParameterEncoder.swift
//  StarWarsWorld
//
//  Created by Francisco Cordoba on 3/9/21.
//

import Foundation

public struct JSONParameterEncoder: ParameterEncoder {
	public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
		do {
			let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
			urlRequest.httpBody = jsonAsData
		} catch {
			throw NetworkError.encodingFailed
		}
	}
}
