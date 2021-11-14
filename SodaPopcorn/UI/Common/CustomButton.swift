//
//  CustomButton.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 12/11/21.
//

import UIKit

public final class CustomButton: UIButton {
    public init(buttonTitle: String? = "") {
        super.init(frame: .zero)
        contentMode = .scaleAspectFit
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(buttonTitle, for: .normal)
        accessibilityLabel = buttonTitle
        tintColor = UIColor(named: "PrimaryColor")
        layer.borderColor = UIColor(named: "PrimaryColor")?.cgColor
        layer.cornerRadius = 10
        layer.borderWidth = 1
        backgroundColor = UIColor(named: "PrimaryColor")?.withAlphaComponent(0.1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
