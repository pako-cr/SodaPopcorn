//
//  CustomBackdropImage.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

import Networking
import UIKit

final class CustomBackdropImage: UIImageView {
    // MARK: - Constants
    private let resetImage: Bool

    // MARK: - Variables
    var backdropSize: BackdropSize = UIDevice.current.isIpad ? .w1280 : .w780

    private var urlString: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let urlString = self.urlString else { return }

                if let cacheImage = cache.value(forKey: "\(self.backdropSize.rawValue)\(urlString)") {
                    self.image = cacheImage
                    self.activityIndicatorView.stopAnimating()

                } else {
                    if self.resetImage {
                        self.image = UIImage(named: "no_backdrop")
                    }

                    self.activityIndicatorView.startAnimating()

                    ImageService.shared().getImage(imagePath: urlString, imageSize: ImageSize(backdropSize: self.backdropSize)) { data, _ in

                        DispatchQueue.main.async { [weak self] in
                            self?.activityIndicatorView.stopAnimating()
                        }

                        DispatchQueue.main.async { [weak self] in
                            guard let `self` = self else { return }

                            guard let data = data else { return }

                            if let newImage = UIImage(data: data) {
                                self.image = newImage
                                cache.insert(newImage, forKey: "\(self.backdropSize.rawValue)\(urlString)")
                            }
                        }
                    }
                }
            }
        }
    }

    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor(named: "PrimaryColor")
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    init(activityIndicatorEnabled: Bool = true, resetImage: Bool = true) {
        self.resetImage = resetImage
        super.init(frame: .zero)
        setupView()

        if !activityIndicatorEnabled {
            self.activityIndicatorView.stopAnimating()
        }
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        sizeToFit()
        contentMode = .scaleAspectFill
        image = UIImage(named: "no_backdrop")

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
}
