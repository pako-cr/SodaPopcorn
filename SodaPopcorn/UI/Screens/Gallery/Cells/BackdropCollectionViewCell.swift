//
//  BackdropCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

import UIKit

final class BackdropCollectionViewCell: UICollectionViewCell {
    // MARK: Constants
    static let reuseIdentifier = "backdropCollectionViewCellId"

    // MARK: Variables
    private var imageURL: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let imageURL = self.imageURL else { return }

                if imageURL.elementsEqual("no_backdrops") {
                    self.backdropImage.isHidden = true
                    self.setEmptyView(title: NSLocalizedString("no_information", comment: "No information"))

                } else {
                    self.backdropImage.setUrlString(urlString: imageURL)
                }
            }
        }
    }

    // MARK: UI Elements
    private let backdropImage = CustomBackdropImage(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellView() {
        addSubview(backdropImage)

        backdropImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backdropImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backdropImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backdropImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // MARK: Helpers
    func configure(with data: String?) {
        self.imageURL = data
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 BackdropCollectionViewCell deinit.")
    }
}
