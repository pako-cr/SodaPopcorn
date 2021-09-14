//
//  NetworkResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Foundation

public enum NetworkResponse: String {
	case success
	case authenticationError = "You need to be authenticated first."
	case badRequest          = "Bad request."
	case outdated            = "The url you requested is outdated."
	case failed              = "Network request failed"
	case noData              = "Response returned with no data to decode."
	case unableToDecode      = "We could not decode the response."
}
