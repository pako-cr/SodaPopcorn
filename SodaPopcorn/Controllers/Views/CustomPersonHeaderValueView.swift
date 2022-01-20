//
//  CustomPersonHeaderValueView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/11/21.
//

import UIKit

public final class CustomPersonHeaderValueView: UIView {
    // MARK: - Consts
    private let header: String

    // MARK: - Vars

    // MARK: - UI Elements
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var headerLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .headline).bold()
        label.textAlignment = .natural
        label.maximumContentSizeCategory = .accessibilityMedium
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.text = self.header
        label.textColor = UIColor.darkGray
        label.sizeToFit()
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.sizeToFit()
        label.text = NSLocalizedString("no_information", comment: "No information")
        return label
    }()

    public init(header: String) {
        self.header = header
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)
        mainStack.addArrangedSubview(headerLabel)
        mainStack.addArrangedSubview(valueLabel)

        mainStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers
    func setValue(value: String) {
        self.valueLabel.text = value
    }
}
