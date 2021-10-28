//
//  CustomImage.swift
//  SodaPopcorn
//
//  Created by Francisco Córdoba on 12/10/21.
//

import UIKit

final class CustomImage: UIImageView {
	private var urlString: String? {
		didSet {
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self, let urlString = self.urlString else { return }

                if let posterImage = cache.value(forKey: self.urlString ?? "") {
                    self.image = posterImage
					self.activityIndicatorView.stopAnimating()

				} else {
					self.image = UIImage(named: "no_poster")
					self.activityIndicatorView.startAnimating()

					PosterImageService.shared().getPosterImage(posterPath: urlString, posterSize: PosterSize.w154) { data, error in

						if error != nil {
							DispatchQueue.main.async { [weak self] in
								guard let `self` = self else { return }
								self.activityIndicatorView.stopAnimating()
								self.image = UIImage(named: "no_poster")
							}
						}

						DispatchQueue.main.async { [weak self] in
							guard let `self` = self else { return }
							self.activityIndicatorView.stopAnimating()

							guard let data = data else { return }

							if let newImage = UIImage(data: data) {
								self.image = newImage
                                cache.insert(newImage, forKey: urlString)
							}
						}
					}
				}
			}
		}
	}

	private let activityIndicatorView: UIActivityIndicatorView = {
		let activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.startAnimating()
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		return activityIndicator
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}

	private func setupView() {
		translatesAutoresizingMaskIntoConstraints = false
		contentMode = .scaleAspectFit
		clipsToBounds = true
		image = UIImage(named: "no_poster")

		addSubview(activityIndicatorView)

		activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		activityIndicatorView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
		activityIndicatorView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true

		if activityIndicatorView.isAnimating {
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) { [weak self] in
				guard let `self` = self else { return }
				self.activityIndicatorView.stopAnimating()
			}
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setUrlString(urlString: String) {
		self.urlString = urlString
	}
}
