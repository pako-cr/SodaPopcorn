//
//  GalleryHeaderReusableView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

import UIKit

final class GalleryHeaderReusableView: UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: GalleryHeaderReusableView.self)
    }

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .headline).bold()
        label.textAlignment = .left
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
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
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
