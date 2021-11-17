//
//  GenreCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 16/11/21.
//

import UIKit

final class GenreCollectionViewCell: UICollectionViewCell {
    // MARK: Constants
    static let reuseIdentifier = "genreCollectionViewCellId"

    // MARK: Variables
    private var genre: Genre? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let genre = self.genre else { return }

                self.genreName.text = genre.name ?? ""
            }
        }
    }

    // MARK: UI Elements
    private let genreImage = CustomBackdropImage(frame: .zero)

    private let genreName: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .headline).bold()
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
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
        addSubview(genreImage)
        addSubview(genreName)

        genreImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        genreImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        genreImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        genreImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        genreName.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        genreName.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        genreName.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        genreName.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.8).isActive = true

    }

    // MARK: Helpers
    func configure(with genre: Genre) {
        self.genre = genre
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 GenreCollectionViewCell deinit.")
    }
}
