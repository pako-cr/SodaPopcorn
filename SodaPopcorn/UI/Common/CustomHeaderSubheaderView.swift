//
//  CustomHeaderSubheaderView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/11/21.
//

import UIKit

public final class CustomHeaderSubheaderView: UIView {
    // MARK: - Consts
    private let header: String

    // MARK: - Vars
    public override var isUserInteractionEnabled: Bool {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }

                self.subheaderLabel.font = UIFont.preferredFont(forTextStyle: .body).italic()
                self.subheaderLabel.textColor = UIColor.systemBlue

                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openWebsite))
                tapGesture.numberOfTapsRequired = 1
                self.addGestureRecognizer(tapGesture)
            }
        }
    }

    // MARK: - UI Elements
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var headerLabel = CustomTitleLabelView(titleText: self.header)

    private let subheaderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.text = NSLocalizedString("no_information", comment: "No information")
        label.sizeToFit()
        return label
    }()

    public init(header: String) {
        self.header = header
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false

        addSubview(mainStack)
        mainStack.addArrangedSubview(headerLabel)
        mainStack.addArrangedSubview(subheaderLabel)

        mainStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers
    func setSubheaderValue(subheader: String) {
        self.subheaderLabel.text = subheader
    }

    @objc
    private func openWebsite() {
        if let websiteUrl = self.subheaderLabel.text, !websiteUrl.isEmpty, let url = URL(string: websiteUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
