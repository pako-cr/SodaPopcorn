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
	private lazy var closeButton: UIButton = {
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

    private let backdropImage: CustomImage = {
        let customImage = CustomImage(frame: .zero)
        customImage.posterSize = .w780
        customImage.customContentMode = .scaleToFill
        customImage.defaultImage = UIImage(named: "no_backdrop")
        return customImage
    }()

    private let movieTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle).bold()
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let releaseDateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let runtimeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let genresLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.text = NSLocalizedString("movie_details_vc_genre_label", comment: "Genre Label")
        return label
    }()

    private let genresValue: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        return label
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
	}

	override func setupUI() {
        view.addSubview(backdropImage)
        view.addSubview(closeButton)
        view.addSubview(movieTitleLabel)
        view.addSubview(releaseDateLabel)
        view.addSubview(runtimeLabel)
        view.addSubview(genresLabel)
        view.addSubview(genresValue)

        backdropImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        backdropImage.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backdropImage.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backdropImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true

        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true

        movieTitleLabel.topAnchor.constraint(equalTo: backdropImage.bottomAnchor, constant: 10).isActive = true
        movieTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        movieTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        movieTitleLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.075).isActive = true

        releaseDateLabel.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor, constant: 0).isActive = true
        releaseDateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        releaseDateLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.08).isActive = true
        releaseDateLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05).isActive = true

        runtimeLabel.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor, constant: 0).isActive = true
        runtimeLabel.leadingAnchor.constraint(equalTo: releaseDateLabel.trailingAnchor).isActive = true
        runtimeLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.2).isActive = true
        runtimeLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05).isActive = true

        genresLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 20).isActive = true
        genresLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        genresLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        genresLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.075).isActive = true

        genresValue.topAnchor.constraint(equalTo: genresLabel.bottomAnchor).isActive = true
        genresValue.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        genresValue.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        genresValue.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.075).isActive = true

	}

	override func bindViewModel() {
		movieInfoSubscription = viewModel.outputs.movieInfoAction()
			.sink(receiveValue: { [weak self] (movie) in
				guard let `self` = self else { return }
				self.handleMovieInfo(movie: movie)
			})
	}

	// MARK: - ⚙️ Helpers
	private func handleMovieInfo(movie: Movie) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            if let backdropImageUrl = movie.backdropPath {
                self.backdropImage.setUrlString(urlString: backdropImageUrl)
            }

            if let movieTitle = movie.title {
                self.movieTitleLabel.text = movieTitle
            }

            if let releaseDate = movie.releaseDate {
                self.releaseDateLabel.text = releaseDate.split(separator: Character.init("-"), maxSplits: 1, omittingEmptySubsequences: true).first?.description ?? ""
            }

            if let genres = movie.genres {
                self.genresValue.text = genres.reduce("", { partialResult, genre in
                    return partialResult + (genre.name ?? "") + " / "
                })
            }

            if let runtime = movie.runtime {
                self.runtimeLabel.text = self.formatRuntime(runtime: runtime)
            }

            print("⭐️ homepage: \(movie.homepage ?? "")")
        }
	}

	@objc
	private func closeButtonPressed() {
		viewModel.inputs.closeButtonPressed()
	}

    // MARK: - Helpers ⚙️
    private func formatRuntime(runtime: Int) -> String {
        guard runtime > 0 else { return "" }

        let stringRuntime = "\((Double.init(runtime) / 60.0).description)"

        let splitRuntime = stringRuntime.split(separator: ".")

        return "﹒ \(splitRuntime[0])h \(splitRuntime[1].prefix(2)) m"
    }

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑 MovieDetailsVC deinit.")
	}
}
