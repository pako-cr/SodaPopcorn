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
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }()

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
        button.tintColor = UIColor(named: "PrimaryColor")
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
        label.sizeToFit()
        return label
    }()

    private let subHeaderStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let releaseDateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private let runtimeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
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

    private let overviewLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.text = NSLocalizedString("movie_details_vc_overview_label", comment: "Overview Label")
        return label
    }()

    private let overviewValue: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.preferredFont(forTextStyle: .body).italic()
        textView.textAlignment = .natural
        textView.isSelectable = false
        textView.isEditable = false
        textView.backgroundColor = .clear
//        textView.isScrollEnabled = true
//        textView.showsVerticalScrollIndicator = true
        return textView
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
        view.addSubview(scrollView)

        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        scrollView.addSubview(backdropImage)
        scrollView.addSubview(closeButton)
        scrollView.addSubview(movieTitleLabel)
        scrollView.addSubview(subHeaderStackView)
        scrollView.addSubview(genresLabel)
        scrollView.addSubview(genresValue)
        scrollView.addSubview(overviewLabel)
        scrollView.addSubview(overviewValue)

        subHeaderStackView.addArrangedSubview(releaseDateLabel)
        subHeaderStackView.addArrangedSubview(runtimeLabel)
        subHeaderStackView.addArrangedSubview(ratingLabel)

        backdropImage.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        backdropImage.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        backdropImage.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.3).isActive = true

        closeButton.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 20).isActive = true

        movieTitleLabel.topAnchor.constraint(equalTo: backdropImage.bottomAnchor, constant: 10).isActive = true
        movieTitleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        movieTitleLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9).isActive = true
        movieTitleLabel.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.05).isActive = true

        subHeaderStackView.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor, constant: 0).isActive = true
        subHeaderStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        subHeaderStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9).isActive = true
        subHeaderStackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.05).isActive = true

        genresLabel.topAnchor.constraint(equalTo: releaseDateLabel.bottomAnchor, constant: 20).isActive = true
        genresLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        genresLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9).isActive = true
        genresLabel.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.05).isActive = true

        genresValue.topAnchor.constraint(equalTo: genresLabel.bottomAnchor).isActive = true
        genresValue.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        genresValue.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9).isActive = true
        genresValue.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.05).isActive = true

        overviewLabel.topAnchor.constraint(equalTo: genresValue.bottomAnchor, constant: 20).isActive = true
        overviewLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        overviewLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9).isActive = true
        overviewLabel.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.05).isActive = true

        overviewValue.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor).isActive = true
        overviewValue.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10).isActive = true
        overviewValue.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.9).isActive = true
        overviewValue.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 1.3).isActive = true
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
            let notApplicableString = NSLocalizedString("not_applicable", comment: "Not applicable")

            if let backdropImageUrl = movie.backdropPath {
                self.backdropImage.setUrlString(urlString: backdropImageUrl)
            }

            self.movieTitleLabel.text = !(movie.title?.isEmpty ?? true) ? movie.title : notApplicableString

            self.releaseDateLabel.text = !(movie.releaseDate?.isEmpty ?? true)
            ? (movie.releaseDate?.split(separator: Character.init("-"), maxSplits: 1, omittingEmptySubsequences: true).first?.description ?? "")
            : notApplicableString

            if let genres = movie.genres {
                if genres.isEmpty { self.genresValue.text = notApplicableString }
                self.genresValue.text = genres.reduce("", { partialResult, genre in

                    return partialResult != ""
                    ? partialResult + " / " + (genre.name ?? "")
                    : partialResult + (genre.name ?? "")
                })
            }

            self.runtimeLabel.text = movie.runtime != nil && (movie.runtime ?? 0) > 0
            ? self.formatRuntime(runtime: movie.runtime ?? 0)
            : notApplicableString

            self.ratingLabel.text = movie.rating != nil && (movie.rating ?? 0.0) > 0.0
            ? "﹒ \(movie.rating ?? 0.0)/10 ⭐️"
            : notApplicableString

            self.overviewValue.text = !(movie.overview?.isEmpty ?? true)
            ? (movie.overview ?? "" )
            : notApplicableString

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
