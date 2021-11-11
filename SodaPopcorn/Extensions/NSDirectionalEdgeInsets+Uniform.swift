//
//  NSDirectionalEdgeInsets+Uniform.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/10/21.
//

import UIKit

extension NSDirectionalEdgeInsets {
	static func uniform(size: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: size, leading: size, bottom: size, trailing: size)
	}

	init(horizontal: CGFloat, vertical: CGFloat) {
		self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
	}

	static func small() -> NSDirectionalEdgeInsets {
		return .uniform(size: 5)
	}

	static func medium() -> NSDirectionalEdgeInsets {
		return .uniform(size: 10)
	}

	static func large() -> NSDirectionalEdgeInsets {
		return .uniform(size: 20)
	}
}
