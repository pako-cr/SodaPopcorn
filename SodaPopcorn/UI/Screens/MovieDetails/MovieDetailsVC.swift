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
    private var imagesSubscription: Cancellable!
    private var socialNetworksSubscription: Cancellable!

    private var oldMovie: Movie?
    private var movie: Movie? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let movie = self.movie else { return }

                // Backdrop
                if let backdropImageUrl = movie.backdropPath, self.oldMovie?.backdropPath != backdropImageUrl {
                    self.backdropCollectionView.updateCollectionViewData(images: [backdropImageUrl])
                }

                // Title
                if let title = movie.title, !title.isEmpty, self.oldMovie?.title != title {
                    self.movieTitleLabel.text = title
                }

                // Tagline
                if let tagline = movie.tagline, !tagline.isEmpty {
                    self.taglineLabel.text = tagline
                    self.taglineLabel.isHidden = false
                }

                // Release Date
                if let releaseDate = movie.releaseDate, !releaseDate.isEmpty, self.oldMovie?.releaseDate != releaseDate {
                    self.releaseDateLabel.text = releaseDate
                        .split(separator: Character.init("-"), maxSplits: 1, omittingEmptySubsequences: true).first?.description ?? ""
                }

                // Genres
                if let genres = movie.genres, !genres.isEmpty {
                    self.genresValue.text = genres.reduce("", { partialResult, genre in
                        return partialResult != "" ? partialResult + " / " + (genre.name ?? "") : partialResult + (genre.name ?? "")
                    })
                }

                // Runtime
                if let runtime = movie.runtime, runtime > 0 {
                    self.runtimeLabel.text = self.formatRuntime(runtime: runtime)
                }

                // Rating
                if let rating = movie.rating, rating > 0.0, self.oldMovie?.rating != rating {
                    self.ratingLabel.text = "﹒ \(movie.rating ?? 0.0)/10 ⭐️"
                }

                // Overview
                if let overview = movie.overview, !overview.isEmpty, self.oldMovie?.overview != overview {
                    self.overviewValue.text = overview
                    self.overviewValue.sizeToFit()
                }

                // Budget
                if let budget = movie.budget, let revenue = movie.revenue, budget > 0, revenue > 0 {
                    self.budgetRevenueValue.text = "\(self.formatCurrency(amount: budget)) / \(self.formatCurrency(amount: revenue))"
                }

                // Homepage
                if let homepage = movie.homepage, !homepage.isEmpty {
                    self.homepageValueButton.setTitle(homepage, for: .normal)
                    self.homepageValueButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).italic()
                    self.homepageValueButton.setTitleColor(UIColor.systemBlue, for: .normal)
                }

                // Production Companies
                if let productionCompanies = movie.productionCompanies, !productionCompanies.isEmpty {
                    self.productionCompaniesValue.text = productionCompanies.reduce("", { partialResult, productionCompany in
                        return partialResult != "" ? partialResult + ", " + (productionCompany.name ?? "") : partialResult + (productionCompany.name ?? "")
                    })

                    self.productionCompaniesValue.sizeToFit()
                }

                self.oldMovie = movie
            }
        }
    }

    // MARK: UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

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

    private lazy var backdropCollectionView: BackdropCollectionView = {
        let collectionView = BackdropCollectionView(movieDetailsVM: self.viewModel)
        collectionView.view.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var galleryButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(galleryButtonPressed), for: .touchUpInside)
        button.accessibilityLabel = NSLocalizedString("gallery", comment: "Gallert button")
        button.tintColor = UIColor(named: "PrimaryColor")
        button.setTitle(NSLocalizedString("gallery", comment: "Gallert button"), for: .normal)
        button.layer.borderColor = UIColor(named: "PrimaryColor")?.cgColor
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        return button
    }()

    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let movieTitleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle).bold()
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        label.sizeToFit()
        label.text = NSLocalizedString("not_applicable", comment: "Not applicable")
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let taglineLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.sizeToFit()
        label.isHidden = true
        return label
    }()

    private let subHeaderStack: UIStackView = {
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
        label.maximumContentSizeCategory = .accessibilityMedium
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.text = NSLocalizedString("not_applicable", comment: "Not applicable")
        label.textColor = UIColor.darkGray
        label.sizeToFit()
        return label
    }()

    private let runtimeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .natural
        label.maximumContentSizeCategory = .accessibilityMedium
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.text = String("﹒ \(NSLocalizedString("not_applicable", comment: "Not applicable"))")
        label.textColor = UIColor.darkGray
        label.sizeToFit()
        return label
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .natural
        label.maximumContentSizeCategory = .accessibilityMedium
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.text = String("﹒ \(NSLocalizedString("not_applicable", comment: "Not applicable"))")
        label.textColor = UIColor.darkGray
        label.sizeToFit()
        return label
    }()

    private let genresLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.text = NSLocalizedString("movie_details_vc_genre_label", comment: "Genre Label")
        label.sizeToFit()
        return label
    }()

    private let genresValue: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.text = NSLocalizedString("not_applicable", comment: "Not applicable")
        label.sizeToFit()
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.text = NSLocalizedString("movie_details_vc_overview_label", comment: "Overview Label")
        label.sizeToFit()
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
        textView.isScrollEnabled = false
        textView.text = NSLocalizedString("movie_details_vc_no_overview_found", comment: "No overview")
        textView.sizeToFit()
        textView.adjustsFontForContentSizeCategory = true
        textView.maximumContentSizeCategory = .accessibilityMedium
        return textView
    }()

    private let budgetRevenueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.text = NSLocalizedString("movie_details_vc_budget_revenue_label", comment: "Budget/revenue label")
        label.sizeToFit()
        return label
    }()

    private let budgetRevenueValue: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.text = NSLocalizedString("not_applicable", comment: "Not applicable")
        label.sizeToFit()
        return label
    }()

    private let productionCompaniesLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.text = NSLocalizedString("movie_details_vc_production_companies_label", comment: "Production companies label")
        label.sizeToFit()
        return label
    }()

    private let productionCompaniesValue: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textAlignment = .natural
        textView.isSelectable = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.text = NSLocalizedString("not_applicable", comment: "Not applicable")
        textView.sizeToFit()
        textView.adjustsFontForContentSizeCategory = true
        textView.maximumContentSizeCategory = .accessibilityMedium
        return textView
    }()

    private let homepageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.text = NSLocalizedString("movie_details_vc_homepage_label", comment: "Homepage label")
        label.sizeToFit()
        return label
    }()

    private lazy var homepageValueButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(openMovieWebsite), for: .touchUpInside)
        button.setTitle(NSLocalizedString("not_applicable", comment: "Not applicable"), for: .normal)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(UIColor.gray, for: .normal)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.maximumContentSizeCategory = .accessibilityMedium
        button.sizeToFit()
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        return button
    }()

    private lazy var socialNetworksCollectionView: SocialNetworksCollectionView = {
        let collectionView = SocialNetworksCollectionView(movieDetailsVM: self.viewModel)
        collectionView.view.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
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
        scrollView.addSubview(contentView)

        scrollView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        contentView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

        headerStack.addArrangedSubview(movieTitleLabel)
        headerStack.addArrangedSubview(taglineLabel)

        contentView.addSubview(backdropCollectionView.view)
        contentView.addSubview(closeButton)
        contentView.addSubview(galleryButton)
        contentView.addSubview(headerStack)
        contentView.addSubview(subHeaderStack)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(overviewValue)
        contentView.addSubview(genresLabel)
        contentView.addSubview(genresValue)
        contentView.addSubview(productionCompaniesLabel)
        contentView.addSubview(productionCompaniesValue)
        contentView.addSubview(budgetRevenueLabel)
        contentView.addSubview(budgetRevenueValue)
        contentView.addSubview(homepageLabel)
        contentView.addSubview(homepageValueButton)
        contentView.addSubview(socialNetworksCollectionView.view)

        subHeaderStack.addArrangedSubview(releaseDateLabel)
        subHeaderStack.addArrangedSubview(runtimeLabel)
        subHeaderStack.addArrangedSubview(ratingLabel)

        backdropCollectionView.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        backdropCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        backdropCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        backdropCollectionView.view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        backdropCollectionView.view.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3).isActive = true

        closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        galleryButton.bottomAnchor.constraint(equalTo: backdropCollectionView.view.bottomAnchor, constant: -10).isActive = true
        galleryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        galleryButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        galleryButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        headerStack.topAnchor.constraint(equalTo: backdropCollectionView.view.bottomAnchor, constant: 10).isActive = true
        headerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true

        subHeaderStack.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 2.5).isActive = true
        subHeaderStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        subHeaderStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        subHeaderStack.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.025).isActive = true

        overviewLabel.topAnchor.constraint(equalTo: subHeaderStack.bottomAnchor, constant: 20).isActive = true
        overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        overviewLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true

        overviewValue.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor).isActive = true
        overviewValue.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        overviewValue.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true

        genresLabel.topAnchor.constraint(equalTo: overviewValue.bottomAnchor, constant: 20).isActive = true
        genresLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        genresLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        genresLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true

        genresValue.topAnchor.constraint(equalTo: genresLabel.bottomAnchor).isActive = true
        genresValue.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        genresValue.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        genresValue.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true

        productionCompaniesLabel.topAnchor.constraint(equalTo: genresValue.bottomAnchor, constant: 20).isActive = true
        productionCompaniesLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        productionCompaniesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        productionCompaniesLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true

        productionCompaniesValue.topAnchor.constraint(equalTo: productionCompaniesLabel.bottomAnchor).isActive = true
        productionCompaniesValue.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        productionCompaniesValue.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true

        budgetRevenueLabel.topAnchor.constraint(equalTo: productionCompaniesValue.bottomAnchor, constant: 20).isActive = true
        budgetRevenueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        budgetRevenueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        budgetRevenueLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true

        budgetRevenueValue.topAnchor.constraint(equalTo: budgetRevenueLabel.bottomAnchor).isActive = true
        budgetRevenueValue.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        budgetRevenueValue.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        budgetRevenueValue.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05).isActive = true

        homepageLabel.topAnchor.constraint(equalTo: budgetRevenueValue.bottomAnchor, constant: 20).isActive = true
        homepageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        homepageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        homepageLabel.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true

        homepageValueButton.topAnchor.constraint(equalTo: homepageLabel.bottomAnchor).isActive = true
        homepageValueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        homepageValueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        homepageValueButton.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.05).isActive = true

        socialNetworksCollectionView.view.topAnchor.constraint(equalTo: homepageValueButton.bottomAnchor, constant: 20).isActive = true
        socialNetworksCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        socialNetworksCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        socialNetworksCollectionView.view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        socialNetworksCollectionView.view.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.175).isActive = true
        socialNetworksCollectionView.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }

    override func bindViewModel() {
        movieInfoSubscription = viewModel.outputs.movieInfoAction()
            .sink(receiveValue: { [weak self] (movie) in
                guard let `self` = self else { return }
                self.movie = movie
            })

        imagesSubscription = viewModel.outputs.backdropImagesAction()
            .sink(receiveValue: { [weak self] backdropImages in
                guard let `self` = self else { return }
                let backdrops = backdropImages.map({ $0.filePath ?? ""})
                self.backdropCollectionView.updateCollectionViewData(images: backdrops)
            })

        socialNetworksSubscription = viewModel.outputs.socialNetworksAction()
            .sink(receiveValue: { [weak self] socialNetworks in
                if let networks = socialNetworks.networks {
                    self?.socialNetworksCollectionView.updateCollectionViewData(socialNetworks: networks)
                }
            })
    }

    // MARK: - ⚙️ Helpers
    @objc
    private func closeButtonPressed() {
        viewModel.inputs.closeButtonPressed()
    }

    @objc
    private func galleryButtonPressed() {
        viewModel.inputs.galleryButtonPressed()
    }

    @objc
    private func openMovieWebsite() {
        if let homepage = self.homepageValueButton.titleLabel?.text, !homepage.isEmpty,
           !homepage.elementsEqual(NSLocalizedString("not_applicable", comment: "Not applicable")),
           let url = URL(string: homepage) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func formatRuntime(runtime: Int) -> String {
        guard runtime > 0 else { return "" }
        let stringRuntime = "\((Double.init(runtime) / 60.0).description)"
        let splitRuntime = stringRuntime.split(separator: ".")
        return "﹒ \(splitRuntime[0])h \(splitRuntime[1].prefix(2)) m"
    }

    private func formatCurrency(amount: Int?) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: (amount ?? 0) as NSNumber) ?? "$0.00"
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑 MovieDetailsVC deinit.")
    }
}
