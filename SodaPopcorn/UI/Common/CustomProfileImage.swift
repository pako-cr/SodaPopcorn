//
//  CustomProfileImage.swift
//  SodaPopcorn
//
//  Created by Francisco Zimplifica on 16/11/21.
//

import UIKit

final class CustomProfileImage: UIImageView {
    // MARK: - Constants
    private let resetImage: Bool

    // MARK: - Variables
    var profileSize: ProfileSize = UIDevice.current.isIpad ? .h632 : .w185

    private var urlString: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let urlString = self.urlString else { return }

                if let cacheImage = cache.value(forKey: "\(self.profileSize.rawValue)\(urlString)") {
                    self.image = cacheImage
                    self.activityIndicatorView.stopAnimating()

                } else {
                    if self.resetImage {
                        self.image = UIImage(named: "no_profile")
                    }

                    self.activityIndicatorView.startAnimating()

                    ImageService.shared().getImage(imagePath: urlString, imageSize: ImageSize(profileSize: self.profileSize)) { data, _ in

                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicatorView.stopAnimating()
                        }

                        DispatchQueue.main.async { [weak self] in
                            guard let `self` = self else { return }

                            guard let data = data else { return }

                            if let newImage = UIImage(data: data) {
                                self.image = newImage
                                cache.insert(newImage, forKey: "\(self.profileSize.rawValue)\(urlString)")
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
        activityIndicator.color = UIColor(named: "PrimaryColor")
        return activityIndicator
    }()

    init(resetImage: Bool = true) {
        self.resetImage = resetImage
        super.init(frame: .zero)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        sizeToFit()
        image = UIImage(named: "no_profile")

        layer.cornerRadius = 10
        layer.borderWidth = 0
        layer.masksToBounds = true
        contentMode = .scaleAspectFill

        addSubview(activityIndicatorView)

        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUrlString(urlString: String) {
        self.urlString = urlString
    }

    func stopActivityIndicator() {
        self.activityIndicatorView.stopAnimating()
    }
}
