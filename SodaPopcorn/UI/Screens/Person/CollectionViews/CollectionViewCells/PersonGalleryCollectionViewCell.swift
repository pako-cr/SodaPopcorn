//
//  PersonGalleryCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 12/11/21.
//

import UIKit

final class PersonGalleryCollectionViewCell: UICollectionViewCell {
    // MARK: Constants
    static let reuseIdentifier = "personGalleryCollectionViewCellId"

    // MARK: Variables
    private var personImage: PersonImage? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let personImage = self.personImage else { return }

                if personImage.filePath == "more_info" {

                    let config = UIImage.SymbolConfiguration(pointSize: 0.1, weight: .ultraLight, scale: .small)
                    let image = UIImage(systemName: "ellipsis.circle", withConfiguration: config)?
                        .withRenderingMode(.alwaysOriginal)
                        .withTintColor(UIColor(named: "PrimaryColor") ?? UIColor.systemOrange)

                    self.posterImage.image = image
                    self.posterImage.contentMode = .scaleAspectFit
                    self.posterImage.stopActivityIndicator()

                } else {
                    if let profilePath = personImage.filePath {
                        self.posterImage.setUrlString(urlString: profilePath)
                    } else {
                        self.posterImage.image = UIImage(named: "no_poster")
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellView() {
        addSubview(posterImage)

        posterImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        posterImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        posterImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        posterImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // MARK: Helpers
    func configure(with personImage: PersonImage?) {
        self.personImage = personImage
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 PersonGalleryCollectionViewCell deinit.")
    }
}
