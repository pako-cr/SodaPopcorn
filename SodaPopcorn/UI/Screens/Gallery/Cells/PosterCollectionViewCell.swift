//
//  PosterCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

import UIKit

final class PosterCollectionViewCell: UICollectionViewCell {
    // MARK: Constants
    static let reuseIdentifier = "posterCollectionViewCellId"

    // MARK: Variables
    private var imageURL: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let imageURL = self.imageURL else { return }

                if imageURL.elementsEqual("no_posters") {
                    self.posterImage.isHidden = true
                    self.setEmptyView(title: NSLocalizedString("no_information", comment: "No information"))
                } else {
                    self.posterImage.setUrlString(urlString: imageURL)
                }
            }
        }
    }

    // MARK: UI Elements
    private let posterImage: CustomPosterImage = {
        let posterImage = CustomPosterImage(frame: .zero)
        posterImage.posterSize = .w342
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
    func configure(with data: String?) {
        self.imageURL = data
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 PosterCollectionViewCell deinit.")
    }
}
