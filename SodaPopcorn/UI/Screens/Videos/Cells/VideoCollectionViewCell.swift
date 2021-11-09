//
//  VideoCollectionViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

import UIKit

final class VideoCollectionViewCell: UICollectionViewCell {
    // MARK: Constants
    static let reuseIdentifier = "videoCollectionViewCellId"

    // MARK: Variables
    private var imageURL: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let imageURL = self.imageURL else { return }
//                self.videoThumbnailImage.setUrlString(urlString: imageURL)
            }
        }
    }

    // MARK: UI Elements
//    private let videoThumbnailImage: CustomImage = {
//        let customImage = CustomImage(frame: .zero)
//        customImage.posterSize = .w780
//        customImage.customContentMode = .scaleAspectFill
//        customImage.defaultImage = UIImage(named: "no_backdrop")
//        customImage.sizeToFit()
//        return customImage
//    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellView() {
//        addSubview(videoThumbnailImage)
//
//        videoThumbnailImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
//        videoThumbnailImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
//        videoThumbnailImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
//        videoThumbnailImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // MARK: Helpers
    func configure(with data: String?) {
        self.imageURL = data
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 VideoCollectionViewCell deinit.")
    }
}
