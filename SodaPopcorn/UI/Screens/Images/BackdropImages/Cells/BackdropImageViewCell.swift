//
//  BackdropImageViewCell.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 22/11/21.
//

import UIKit

final class BackdropImageViewCell: UICollectionViewCell, UIScrollViewDelegate {
    // MARK: Constants
    static let reuseIdentifier = "backdropImageViewCellId"

    // MARK: Variables
    private var parentViewController: UIViewController?

    private var imageURL: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let imageURL = self.imageURL else { return }

                if let cacheImage = cache.value(forKey: "\(BackdropSize.w780.rawValue)\(imageURL)") {
                    self.backdropImage.image = cacheImage
                    self.backdropImage.contentMode = .scaleAspectFit
                }

                self.backdropImage.contentMode = ContentMode.scaleAspectFit
                self.backdropImage.backdropSize = .original
                self.backdropImage.setUrlString(urlString: imageURL)
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

    private let backdropImage = CustomBackdropImage(resetImage: false)

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

        scrollContentView.addSubview(backdropImage)

        backdropImage.topAnchor.constraint(equalTo: scrollContentView.topAnchor).isActive = true
        backdropImage.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor).isActive = true
        backdropImage.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor).isActive = true
        backdropImage.bottomAnchor.constraint(equalTo: scrollContentView.bottomAnchor).isActive = true
        backdropImage.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0).isActive = true

        handleGestureRecongnizers()
    }

    // MARK: Helpers
    func configure(with data: String?, parentViewController: UIViewController) {
        self.imageURL = data
        self.parentViewController = parentViewController
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return backdropImage
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
        guard let image = backdropImage.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    // MARK: - 🗑 Deinit
    deinit {
        //        print("🗑 BackdropImageViewCell deinit.")
    }
}
