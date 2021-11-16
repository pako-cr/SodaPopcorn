//
//  CastCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 10/11/21.
//

import UIKit

final class CastCollectionViewCell: UICollectionViewCell {
    // MARK: Constants
    static let reuseIdentifier = "castCollectionViewCellId"

    // MARK: Variables
    private var cast: Cast? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let cast = self.cast else { return }

                if cast.name == "more_info" {

                    let config = UIImage.SymbolConfiguration(pointSize: 0.1, weight: .ultraLight, scale: .small)
                    let image = UIImage(systemName: "ellipsis.circle", withConfiguration: config)?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(UIColor(named: "PrimaryColor") ?? UIColor.systemOrange)

                    self.profileImage.image = image
                    self.profileImage.contentMode = .scaleAspectFit
                    self.castName.isHidden = true
                    self.characterName.isHidden = true

                } else {
                    self.castName.isHidden = false
                    self.characterName.isHidden = false

                    self.profileImage.contentMode = .scaleAspectFill
                    if let profilePath = cast.profilePath {
                        self.profileImage.setUrlString(urlString: profilePath)
                    } else {
                        self.profileImage.image = UIImage(named: "no_poster")
                    }

                    if let castName = cast.name {
                        self.castName.text = castName
                    }

                    if let characterName = cast.character {
                        self.characterName.text = characterName
                    }
                }
            }
        }
    }

    // MARK: UI Elements
    private let profileImage = CustomProfileImage(frame: .zero)

    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let castName: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .caption1).bold()
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.sizeToFit()
        return label
    }()

    private let characterName: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.sizeToFit()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellView() {
        addSubview(profileImage)
        addSubview(mainStack)

        mainStack.addArrangedSubview(castName)
        mainStack.addArrangedSubview(characterName)

        profileImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        profileImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        profileImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        profileImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true

        mainStack.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 2.0).isActive = true
        mainStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        mainStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        mainStack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    }

    // MARK: Helpers
    func configure(with cast: Cast?) {
        self.cast = cast
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 CastCollectionViewCell deinit.")
    }
}
