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

    private let headerLabel = CustomTitleLabelView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black

        addSubview(headerLabel)

        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerLabel.topAnchor.constraint(equalTo: topAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with headerTitle: String) {
        self.headerLabel.text = headerTitle
    }
}
