//
//  CustomVideoThumbnail.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

import UIKit

final class CustomVideoThumbnail: UIImageView {
    // MARK: - Variables

    private var urlString: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let urlString = self.urlString else { return }

                if let posterImage = cache.value(forKey: urlString) {
                    self.image = posterImage
                    self.activityIndicatorView.stopAnimating()

                } else {
                    self.activityIndicatorView.startAnimating()
//                    print("⭐️ getVideoThumbnail \(urlString) with backdrop size: \(self.posterSize)")
                    ImageService.shared().getVideoThumbnail(videoUrl: urlString) { data, error in

                        if error != nil {
                            DispatchQueue.main.async { [weak self] in
                                guard let `self` = self else { return }
                                self.activityIndicatorView.stopAnimating()
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
        activityIndicator.color = UIColor(named: "PrimaryColor")
        return activityIndicator
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
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
