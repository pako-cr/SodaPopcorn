//
//  ProfileCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Zimplifica on 16/11/21.
//

import UIKit

final class ProfileCollectionViewCell: UICollectionViewCell {
    // MARK: Constants
    static let reuseIdentifier = "profileCollectionViewCellId"

    // MARK: Variables
    private var imageURL: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let imageURL = self.imageURL else { return }

                if imageURL == "more_info" {

                    let config = UIImage.SymbolConfiguration(pointSize: 0.1, weight: .ultraLight, scale: .small)
                    let image = UIImage(systemName: "ellipsis.circle", withConfiguration: config)?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(UIColor(named: "PrimaryColor") ?? UIColor.systemOrange)

                    self.profileImage.image = image
                    self.profileImage.contentMode = .scaleAspectFit
                    self.profileImage.stopActivityIndicator()

                } else {
                    self.profileImage.setUrlString(urlString: imageURL)
                }
            }
        }
    }

    // MARK: UI Elements
    private let profileImage = CustomProfileImage(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellView() {
        addSubview(profileImage)

        profileImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        profileImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        profileImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // MARK: Helpers
    func configure(with data: String?) {
        self.imageURL = data
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 ProfileCollectionViewCell deinit.")
    }
}
