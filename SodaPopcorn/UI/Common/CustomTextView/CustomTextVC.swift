//
//  CustomTextVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

import Combine
import UIKit

final class CustomTextVC: BaseViewController {
    // MARK: Consts
    private let viewModel: CustomTextVM

    // MARK: - Variables
    private var textSubscription: Cancellable!

    // MARK: UI Elements
    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        button.accessibilityLabel = NSLocalizedString("close", comment: "Close button")
        button.tintColor = UIColor(named: "PrimaryColor")
        return button
    }()

    private var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.preferredFont(forTextStyle: .body).italic()
        textView.textAlignment = .natural
        textView.isSelectable = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.text = NSLocalizedString("movie_details_vc_no_overview_found", comment: "No overview")
        textView.sizeToFit()
        textView.adjustsFontForContentSizeCategory = true
        textView.maximumContentSizeCategory = .accessibilityMedium
        return textView
    }()

    init(viewModel: CustomTextVM) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        setupUI()
        bindViewModel()
        viewModel.inputs.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    override func setupUI() {
        view.addSubview(textView)
        view.addSubview(closeButton)

        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        textView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 10).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override func bindViewModel() {
        textSubscription = viewModel.outputs.textAction()
            .sink(receiveValue: { [weak self] text in
                guard let `self` = self else { return }
                self.textView.text = text
            })
    }

    // MARK: - ⚙️ Helpers
    @objc
    private func closeButtonPressed() {
        viewModel.inputs.closeButtonPressed()
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑", "CustomTextVC deinit.")
    }
}
