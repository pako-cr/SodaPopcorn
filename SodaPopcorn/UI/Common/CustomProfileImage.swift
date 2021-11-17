//
//  CustomProfileImage.swift
//  SodaPopcorn
//
//  Created by Francisco Zimplifica on 16/11/21.
//

import UIKit

final class CustomProfileImage: UIImageView {
    // MARK: - Variables
    var profileSize = ProfileSize.w185

    private var urlString: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let urlString = self.urlString else { return }

                if let cacheImage = cache.value(forKey: "\(self.profileSize.rawValue)\(urlString)") {
                    self.image = cacheImage
                    self.activityIndicatorView.stopAnimating()

                } else {
                    self.activityIndicatorView.startAnimating()
//                    print("⭐️ getProfileImage \(urlString) with poster size: \(self.posterSize)")
                    ImageService.shared().getImage(imagePath: urlString, imageSize: ImageSize(profileSize: self.profileSize)) { data, error in

                        if error != nil {
                            DispatchQueue.main.async { [weak self] in
                                guard let `self` = self else { return }
                                self.image = UIImage(named: "no_profile")
                                self.activityIndicatorView.stopAnimating()
                            }
                        }

                        DispatchQueue.main.async { [weak self] in
                            guard let `self` = self else { return }
                            self.activityIndicatorView.stopAnimating()

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

    override init(frame: CGRect) {
        super.init(frame: frame)
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

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) { [weak self] in
            self?.activityIndicatorView.stopAnimating()
        }
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
