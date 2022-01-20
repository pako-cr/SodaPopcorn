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
    private var videoURL: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let videoURL = self.videoURL else { return }

                if videoURL.elementsEqual("no_videos") {
                    self.videoThumbnailImage.isHidden = true
                    self.playVideoButton.isHidden = true
                    self.setEmptyView(title: NSLocalizedString("no_information", comment: "No information"))
                } else {
                    self.videoThumbnailImage.setUrlString(urlString: videoURL)
                }
            }
        }
    }

    // MARK: UI Elements
    private let videoThumbnailImage = CustomVideoThumbnail(frame: .zero)

    private lazy var playVideoButton: UIButton = {
        let config = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.largeTitle))
        let image = UIImage(systemName: "play.rectangle.fill", withConfiguration: config)

        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = NSLocalizedString("close", comment: "Close button")
        button.tintColor = UIColor(named: "PrimaryColor")
        button.isUserInteractionEnabled = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellView() {
        addSubview(videoThumbnailImage)
        addSubview(playVideoButton)

        videoThumbnailImage.topAnchor.constraint(equalTo: topAnchor).isActive = true
        videoThumbnailImage.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        videoThumbnailImage.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        videoThumbnailImage.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        playVideoButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        playVideoButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playVideoButton.widthAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        playVideoButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
    }

    // MARK: Helpers
    func configure(with data: String?) {
        self.videoURL = data
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 VideoCollectionViewCell deinit.")
    }
}
