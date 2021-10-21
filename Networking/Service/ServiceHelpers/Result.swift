//
//  Result.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 4/9/21.
//

import Foundation

public enum Result<T: Equatable>: Equatable {
	case success(T)
	case failure(Error)

	public static func == (lhs: Result<T>, rhs: Result<T>) -> Bool {
		return true
	}
}
