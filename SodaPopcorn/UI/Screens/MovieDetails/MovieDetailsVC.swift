//
//  MovieDetailsVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 7/10/21.
//

import Combine
import UIKit

final class MovieDetailsVC: BaseViewController {
	// MARK: Consts
	private let viewModel: MovieDetailsVM

	// MARK: - Variables
	private var movieInfoSubscription: Cancellable!

	// MARK: UI Elements
	private let closeButton: UIButton = {
		let image = UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate)
		let button = UIButton(type: UIButton.ButtonType.system)
		button.setImage(image, for: .normal)
		button.setTitleColor(UIColor.secondaryLabel, for: .normal)
		button.contentMode = .scaleAspectFit
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
		button.titleLabel?.adjustsFontSizeToFitWidth = true
		button.titleLabel?.adjustsFontForContentSizeCategory = true
		button.accessibilityLabel = NSLocalizedString("close", comment: "Close button")
		return button
	}()

	init(viewModel: MovieDetailsVM) {
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

//		let appearance = UINavigationBarAppearance()
//		appearance.configureWithDefaultBackground()
//		appearance.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
//		navigationController?.navigationBar.standardAppearance = appearance
//		navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
//
//		navigationItem.standardAppearance = appearance
	}

	override func setupUI() {
		view.addSubview(closeButton)

		closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
		closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
		closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
		closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
	}

	override func bindViewModel() {
		movieInfoSubscription = viewModel.outputs.movieInfoAction()
			.sink(receiveValue: { [weak self] (movie) in
				guard let `self` = self, let movie = movie else { return }
				self.handleMovieInfo(movie: movie)
			})
	}

	// MARK: - ⚙️ Helpers
	private func handleMovieInfo(movie: Movie) {
		print("🔸 handleMovieInfo: \(movie.title ?? "no-title")")
		navigationItem.title = movie.title ?? ""
	}

	@objc
	private func closeButtonPressed() {
		viewModel.inputs.closeButtonPressed()
	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑 MovieDetailsVC deinit.")
	}
}
