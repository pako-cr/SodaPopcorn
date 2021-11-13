//
//  UICollectionView+EmptyView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/9/21.
//

import UIKit

extension UICollectionView {
	/// Sets an empty view when a collection is empty or is loading.
    func setEmptyView(title: String, message: String, centeredX: Bool = true, centeredY: Bool = false) {
        let emptyView: UIView = {
            let emptyView = UIView(frame: .zero)
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            return emptyView
        }()

		let stack: UIStackView = {
			let stack = UIStackView()
			stack.axis = .vertical
			stack.distribution = .fillProportionally
			stack.alignment = .fill
			stack.translatesAutoresizingMaskIntoConstraints = false
			return stack
		}()

		let titleLabel: UILabel = {
			let label = UILabel()
			label.font = UIFont.preferredFont(forTextStyle: .headline).bold()
			label.text = title
			label.numberOfLines = 0
            label.textAlignment = centeredX ? .center : .left
			label.adjustsFontSizeToFitWidth = true
			label.adjustsFontForContentSizeCategory = true
			label.accessibilityLabel = title
			label.accessibilityHint = "No information title"
			return label
		}()

		let messageLabel: UILabel = {
			let label = UILabel()
			label.textColor = UIColor.lightGray
			label.font =  UIFont.preferredFont(forTextStyle: .subheadline)
			label.text = message
			label.numberOfLines = 2
			label.textAlignment = centeredX ? .center : .left
			label.adjustsFontSizeToFitWidth = true
			label.adjustsFontForContentSizeCategory = true
			label.accessibilityLabel = message
			label.accessibilityHint = "No information description"
			return label
		}()

		self.backgroundView = emptyView

		emptyView.addSubview(stack)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(messageLabel)

        emptyView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        emptyView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        emptyView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        emptyView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

        stack.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 10).isActive = true
		stack.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: -10).isActive = true
        stack.heightAnchor.constraint(equalToConstant: 50.0).isActive = true

		if centeredY {
			stack.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
		} else {
            stack.topAnchor.constraint(equalTo: emptyView.safeAreaLayoutGuide.topAnchor).isActive = true
		}
	}

	/// Restore the collection view when a datasource is fetched.
	func removeEmptyView() {
		self.backgroundView = nil
	}
}

extension UICollectionViewCell {
    /// Sets an empty view when a collection is empty.
    func setEmptyView(title: String, centered: Bool = false) {
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))

        let titleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.preferredFont(forTextStyle: .subheadline)
            label.text = title
            label.numberOfLines = 0
            label.textAlignment = .left
            label.adjustsFontForContentSizeCategory = true
            label.translatesAutoresizingMaskIntoConstraints = false
            label.accessibilityLabel = title
            label.accessibilityHint = "No information title"
            return label
        }()

        self.backgroundView = emptyView

        emptyView.addSubview(titleLabel)

        titleLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: emptyView.heightAnchor, multiplier: 0.3).isActive = true
        titleLabel.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 10).isActive = true
    }

    /// Restore the collection view when a datasource is fetched.
    func removeEmptyView() {
        self.backgroundView = nil
    }
}
