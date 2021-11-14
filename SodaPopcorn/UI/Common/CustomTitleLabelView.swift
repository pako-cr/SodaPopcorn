//
//  CustomTitleLabelView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 12/11/21.
//

import UIKit

public final class CustomTitleLabelView: UILabel {
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "PrimaryColor")
        view.alpha = 1.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public init(titleText: String? = "") {
        super.init(frame: .zero)

        addSubview(separatorView)
        separatorView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        separatorView.widthAnchor.constraint(equalToConstant: 3.0).isActive = true
        separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -10).isActive = true
        separatorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true

        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 30).isActive = true
        numberOfLines = 1
        font = UIFont.preferredFont(forTextStyle: .headline)
        textAlignment = .left
        adjustsFontForContentSizeCategory = true
        maximumContentSizeCategory = .accessibilityMedium
        text = titleText
        sizeToFit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
