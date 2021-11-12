//
//  CreditsHeaderReusableView.swift
//  SodaPopcorn
//
//  Created by Francisco Zimplifica on 10/11/21.
//

import UIKit

final class CreditsHeaderReusableView: UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: CreditsHeaderReusableView.self)
    }

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .headline).bold()
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.sizeToFit()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black

        addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.widthAnchor.constraint(equalTo: widthAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with headerTitle: String) {
        self.headerLabel.text = headerTitle
    }
}
