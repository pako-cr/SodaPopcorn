//
//  ImageViewVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

import Combine
import UIKit

final class ImageViewVC: BaseViewController, UIScrollViewDelegate {
    // MARK: Consts
    private let viewModel: ImageViewVM

    // MARK: - Variables
    private var imageURLSubscription: Cancellable!
    private var imageURL: String? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let imageURL = self.imageURL else { return }
                self.backdropImage.setUrlString(urlString: imageURL)
            }
        }
    }

    // MARK: UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        return scrollView
    }()

    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        button.accessibilityLabel = NSLocalizedString("close", comment: "Close button")
        button.tintColor = UIColor(named: "PrimaryColor")
        return button
    }()

    private let backdropImage: CustomImage = {
        let customImage = CustomImage(frame: .zero)
        customImage.posterSize = .original
        customImage.customContentMode = .scaleAspectFit
        customImage.defaultImage = UIImage(named: "no_backdrop")
        customImage.sizeToFit()
        return customImage
    }()

    init(viewModel: ImageViewVM) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.inputs.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    override func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.delegate = self

        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

        contentView.addSubview(closeButton)
        contentView.addSubview(backdropImage)

        closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true

        backdropImage.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        backdropImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        backdropImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        backdropImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        backdropImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1.0).isActive = true
    }

    override func bindViewModel() {
        imageURLSubscription = viewModel.outputs.imageURLAction()
            .sink(receiveValue: { [weak self] (imageURL) in
                guard let `self` = self else { return }
                self.imageURL = imageURL
            })
    }

    // MARK: - Helpers ⚙️
    @objc
    private func closeButtonPressed() {
        viewModel.inputs.closeButtonPressed()
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.backdropImage
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑 ImageViewVC deinit.")
    }
}
