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

                    let config = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.caption1), scale: UIImage.SymbolScale.small)
                    let image = UIImage(systemName: "plus", withConfiguration: config)?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(UIColor(named: "PrimaryColor") ?? UIColor.systemOrange)

                    self.posterImage.image = image
                    self.posterImage.contentMode = .scaleAspectFit
                    self.castName.isHidden = true
                    self.characterName.isHidden = true

                } else {
                    self.castName.isHidden = false
                    self.characterName.isHidden = false

                    self.posterImage.contentMode = .scaleAspectFill
                    if let profilePath = cast.profilePath {
                        self.posterImage.setUrlString(urlString: profilePath)
                    } else {
                        self.posterImage.image = UIImage(named: "no_poster")
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
    private let posterImage: CustomPosterImage = {
        let posterImage = CustomPosterImage(frame: .zero)
        posterImage.posterSize = .w342
        posterImage.layer.cornerRadius = 10
        posterImage.layer.borderWidth = 0
        posterImage.layer.masksToBounds = true
        posterImage.contentMode = .scaleAspectFill
        return posterImage
    }()

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
        addSubview(posterImage)
        addSubview(mainStack)

        mainStack.addArrangedSubview(castName)
        mainStack.addArrangedSubview(characterName)

        posterImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        posterImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        posterImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        posterImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true

        mainStack.topAnchor.constraint(equalTo: posterImage.bottomAnchor, constant: 2.0).isActive = true
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
