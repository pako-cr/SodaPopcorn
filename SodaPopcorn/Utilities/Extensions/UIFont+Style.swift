//
//  UIFont+Style.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 6/9/21.
//

import UIKit

extension UIFont {
	private func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
		let descriptor = fontDescriptor.withSymbolicTraits(traits)
		return UIFont(descriptor: descriptor!, size: 0) // Note: Size 0 means keep the size as it is.
	}

	func bold() -> UIFont {
		return withTraits(traits: .traitBold)
	}

	func italic() -> UIFont {
		return withTraits(traits: .traitItalic)
	}
}
