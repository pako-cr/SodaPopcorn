//
//  SectionFooterReusableView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 8/10/21.
//

import UIKit

final class SectionFooterReusableView: UICollectionReusableView {
	static var reuseIdentifier: String {
		return String(describing: SectionFooterReusableView.self)
	}

	private let activityIndicator: UIActivityIndicatorView = {
		let activity = UIActivityIndicatorView(style: .medium)
		activity.translatesAutoresizingMaskIntoConstraints = false
		activity.startAnimating()
		return activity
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = .systemBackground
		addSubview(activityIndicator)

		NSLayoutConstraint.activate([
			activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
			activityIndicator.topAnchor.constraint(equalTo: topAnchor),
			activityIndicator.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
			activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
