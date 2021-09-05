//
//  Result.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 4/9/21.
//

import Foundation

public enum Result<T: Equatable>: Equatable {
	case success(T)
	case failure(String)

	public static func == (lhs: Result<T>, rhs: Result<T>) -> Bool {
		return true
	}
}
