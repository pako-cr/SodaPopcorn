//
//  ActivityIndicatorFooterReusableView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 8/10/21.
//

import UIKit

final class ActivityIndicatorFooterReusableView: UICollectionReusableView {
	static var reuseIdentifier: String {
		return String(describing: ActivityIndicatorFooterReusableView.self)
	}

	private let activityIndicator: UIActivityIndicatorView = {
		let activity = UIActivityIndicatorView(style: .medium)
		activity.translatesAutoresizingMaskIntoConstraints = false
        activity.color = UIColor(named: "PrimaryColor")
		return activity
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.preferredFont(forTextStyle: .caption1).bold()
		label.adjustsFontSizeToFitWidth = true
		label.numberOfLines = 1
		label.textAlignment = .center
		label.text = NSLocalizedString("end_of_the_list", comment: "End of the list")
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)

		backgroundColor = .systemBackground
		addSubview(activityIndicator)

		NSLayoutConstraint.activate([
			activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
			activityIndicator.topAnchor.constraint(equalTo: topAnchor),
			activityIndicator.widthAnchor.constraint(equalTo: widthAnchor),
			activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
		])
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func stopActivityIndicator() {
		activityIndicator.stopAnimating()

		addSubview(titleLabel)

		titleLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
		titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
		titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
		titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
	}

	func startActivityIndicator() {
		activityIndicator.startAnimating()
		titleLabel.removeFromSuperview()
	}
}
