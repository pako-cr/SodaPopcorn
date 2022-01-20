//
//  PosterImageViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 22/11/21.
//

import UIKit

final class PosterImageViewCell: UICollectionViewCell, UIScrollViewDelegate {
    // MARK: Constants
    static let reuseIdentifier = "posterImageViewCellId"

    // MARK: Variables
    private var parentViewController: UIViewController?

    private var imageURL: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let imageURL = self.imageURL else { return }

                if let cacheImage = cache.value(forKey: "\(PosterSize.w342.rawValue)\(imageURL)") {
                    self.posterImage.image = cacheImage
                    self.posterImage.contentMode = .scaleAspectFit
                }

                self.posterImage.contentMode = .scaleAspectFit
                self.posterImage.posterSize = .original
                self.posterImage.setUrlString(urlString: imageURL)
            }
        }
    }

    // MARK: UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()

    private let scrollContentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    private let posterImage = CustomPosterImage(resetImage: false)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellView() {
        addSubview(scrollView)
        scrollView.addSubview(scrollContentView)

        scrollView.delegate = self

        scrollView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        scrollContentView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        scrollContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

        scrollContentView.addSubview(posterImage)

        posterImage.topAnchor.constraint(equalTo: scrollContentView.topAnchor).isActive = true
        posterImage.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor).isActive = true
        posterImage.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor).isActive = true
        posterImage.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor).isActive = true
        posterImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0).isActive = true

        handleGestureRecongnizers()
    }

    // MARK: Helpers
    func configure(with data: String?, parentViewController: UIViewController) {
        self.imageURL = data
        self.parentViewController = parentViewController
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return posterImage
    }

    private func handleGestureRecongnizers() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(presentImageOptionsActionSheet))
        longPressRecognizer.minimumPressDuration = 1.0

        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureZoomAction))
        doubleTapRecognizer.numberOfTapsRequired = 2

        isUserInteractionEnabled = true
        addGestureRecognizer(longPressRecognizer)
        addGestureRecognizer(doubleTapRecognizer)

        scrollView.addGestureRecognizer(doubleTapRecognizer)
    }

    @objc
    private func tapGestureZoomAction(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale > 5.0 {
            scrollView.setZoomScale(1.0, animated: true)

        } else {
            let coordinates = recognizer.location(in: self)

            let zoomRect = CGRect(x: coordinates.x,
                                  y: coordinates.y,
                                  width: .zero,
                                  height: .zero)
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }

    @objc
    private func presentImageOptionsActionSheet() {
        let saveAction = UIAlertAction(title: NSLocalizedString("alert_save_button", comment: "Save button"), style: .default) { [weak self] _ in
            self?.downloadImageToPhotosAlbum()
        }

        if let viewController = self.parentViewController {
            Alert.showActionSheet(on: viewController, actions: [saveAction])
        }
    }

    @objc
    private func downloadImageToPhotosAlbum() {
        guard let image = posterImage.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 PosterImageViewCell deinit.")
    }
}
