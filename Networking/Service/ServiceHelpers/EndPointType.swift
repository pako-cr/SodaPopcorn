//
//  EndPointType.swift
//  StarWarsWorld
//
//  Created by Zimplifica Macbook Pro on 3/9/21.
//

import Foundation

protocol EndPointType {
	var baseURL: URL { get }
	var path: String { get }
	var cachePolicy: URLRequest.CachePolicy { get }
	var httpMethod: HTTPMethod { get }
	var task: HTTPTask { get }
	var headers: HTTPHeaders? { get }
}
