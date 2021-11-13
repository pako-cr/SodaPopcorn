//
//  CustomTextView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 12/11/21.
//

import UIKit

public final class CustomTextView: UITextView {
    public init(customText: String? = "") {
        super.init(frame: .zero, textContainer: nil)

        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.preferredFont(forTextStyle: .subheadline)
        textAlignment = .natural
        isSelectable = false
        isEditable = false
        backgroundColor = .clear
        isScrollEnabled = false
        text = customText
        sizeToFit()
        adjustsFontForContentSizeCategory = true
        maximumContentSizeCategory = .accessibilityMedium
        textContainer.lineBreakMode = .byTruncatingTail
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
