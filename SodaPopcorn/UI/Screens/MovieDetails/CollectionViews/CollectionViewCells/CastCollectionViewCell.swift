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

                if cast == Cast() {
                    self.posterImage.isHidden = true
                    self.setEmptyView(title: NSLocalizedString("No Cast", comment: "No cast"))

                } else {
                    self.posterImage.setUrlString(urlString: cast.profilePath ?? "")
                    self.castName.text = cast.name
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
        return posterImage
    }()

    private let castName: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
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
        addSubview(castName)

        posterImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        posterImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        posterImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        posterImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true

        castName.topAnchor.constraint(equalTo: posterImage.bottomAnchor, constant: 2.0).isActive = true
        castName.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        castName.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        castName.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
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
