//
//  SocialNetworksCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 7/11/21.
//

import UIKit

final class SocialNetworksCollectionViewCell: UICollectionViewCell {
    // MARK: Constants
    static let reuseIdentifier = "socialNetworksCollectionViewCellId"

    // MARK: Variables
    private var socialNetwork: SocialNetwork? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let socialNetwork = self.socialNetwork else { return }

                switch socialNetwork {
                case .instagram:
                    self.logoImage.image = UIImage(named: "instagram_logo")
                case .facebook:
                    self.logoImage.image = UIImage(named: "facebook_logo")
                case .twitter:
                    self.logoImage.image = UIImage(named: "twitter_logo")
                }
            }
        }
    }

    // MARK: UI Elements
    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "no_poster")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.sizeToFit()
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellView() {
        addSubview(logoImage)

        logoImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        logoImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        logoImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        logoImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // MARK: Helpers
    func configure(with socialNetwork: SocialNetwork?) {
        self.socialNetwork = socialNetwork
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 SocialNetworksCollectionViewCell deinit.")
    }
}
