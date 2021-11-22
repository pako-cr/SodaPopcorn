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
    private let pushedViewController: Bool

    // MARK: - Variables
    private var movieInfoSubscription: Cancellable!
    private var imagesSubscription: Cancellable!
    private var socialNetworksSubscription: Cancellable!
    private var castSubscription: Cancellable!
    private var similarMoviesSubscription: Cancellable!

    // MARK: Constraints
    private var backdropImageHeightAnchor: NSLayoutConstraint?
    private var castHeightAnchor: NSLayoutConstraint?
    private var similarMoviesHeightAnchor: NSLayoutConstraint?
    private var socialNetworksHeightAnchor: NSLayoutConstraint?

    private let headerHeight: CGFloat = 300

    private var oldMovie: Movie?
    private var movie: Movie? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let movie = self.movie else { return }

                // Backdrop
                if self.oldMovie?.backdropPath != movie.backdropPath {
                    self.backdropImage.setUrlString(urlString: movie.backdropPath ?? "")
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
                    let genres = genres.reduce("", { partialResult, genre in
                        return partialResult != "" ? partialResult + " / " + (genre.name ?? "") : partialResult + (genre.name ?? "")
                    })

                    self.genresInformation.setSubheaderValue(subheader: genres)
                }

                // Runtime
                if let runtime = movie.runtime, runtime > 0 {
                    self.runtimeLabel.text = self.formatRuntime(runtime: runtime)
                }

                // Rating
                if let rating = movie.rating, rating > 0.0, self.oldMovie?.rating != rating {
                    self.ratingScoreChartView.setRatingValue(ratingValue: movie.rating ?? 0.0)
                }

                // Overview
                if let overview = movie.overview, !overview.isEmpty, self.oldMovie?.overview != overview {
                    self.overviewValue.text = overview
                    self.overviewValue.sizeToFit()
                }

                // Budget
                if let budget = movie.budget, let revenue = movie.revenue, budget > 0, revenue > 0 {
                    self.budgetRevenueInformation.setSubheaderValue(subheader: "\(self.formatCurrency(amount: budget)) / \(self.formatCurrency(amount: revenue))")
                }

                // Production Companies
                if let productionCompanies = movie.productionCompanies, !productionCompanies.isEmpty {
                    let productionCompanies = productionCompanies.reduce("", { partialResult, productionCompany in
                        return partialResult != "" ? partialResult + ", " + (productionCompany.name ?? "") : partialResult + (productionCompany.name ?? "")
                    })

                    self.productionCompaniesInformation.setSubheaderValue(subheader: productionCompanies)
                }

                // Website
                if let website = movie.homepage, !website.isEmpty {
                    self.websiteInformation.setSubheaderValue(subheader: website)
                    self.websiteInformation.isUserInteractionEnabled = true
                }

                self.oldMovie = movie
            }
        }
    }

    // MARK: UI Elements
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()

    private let contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        return contentView
    }()

    private let backdropImage = CustomBackdropImage()

    private lazy var ratingScoreChartView = RatingScoreChartView(ratingValue: self.movie?.rating ?? 0.0)

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
        label.text = NSLocalizedString("no_information", comment: "No information")
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
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.textColor = UIColor.darkGray
        label.sizeToFit()
        return label
    }()

    private let genresInformation = CustomHeaderSubheaderView(header: NSLocalizedString("movie_details_vc_genre_label", comment: "Genre Label"))

    private let overviewLabel = CustomTitleLabelView(titleText: NSLocalizedString("movie_details_vc_overview_label", comment: "Overview Label"))

    private let overviewValue = CustomTextView(customText: NSLocalizedString("movie_details_vc_no_overview_found", comment: "No overview"))

    private let productionCompaniesInformation = CustomHeaderSubheaderView(header: NSLocalizedString("movie_details_vc_production_companies_label", comment: "Production companies label"))

    private let budgetRevenueInformation = CustomHeaderSubheaderView(header: NSLocalizedString("movie_details_vc_budget_revenue_label", comment: "Budget/revenue label"))

    private lazy var castCollectionView = CastCollectionView(viewModel: self.viewModel)

    private lazy var similarMoviesCollectionView = SimilarMoviesCollectionView(viewModel: self.viewModel)

    private let socialNetworksCollectionView = SocialNetworksCollectionView()

    private let websiteInformation = CustomHeaderSubheaderView(header: NSLocalizedString("website", comment: "Website"))

    init(viewModel: MovieDetailsVM, pushedViewController: Bool = false) {
        self.viewModel = viewModel
        self.pushedViewController = pushedViewController
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad()
        handleGestureRecongnizers()
        setupNavigationBar()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        castHeightAnchor?.constant = view.bounds.height * (UIWindow.isLandscape ? 0.6 : 0.3)
        similarMoviesHeightAnchor?.constant = view.bounds.height * (UIWindow.isLandscape ? 0.8 : 0.3)
        socialNetworksHeightAnchor?.constant = view.bounds.height * (UIWindow.isLandscape ? 0.3 : 0.15)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
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

        contentView.addSubview(backdropImage)
        contentView.addSubview(ratingScoreChartView)
        contentView.addSubview(headerStack)
        contentView.addSubview(subHeaderStack)
        contentView.addSubview(genresInformation)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(overviewValue)
        contentView.addSubview(productionCompaniesInformation)
        contentView.addSubview(budgetRevenueInformation)
        contentView.addSubview(castCollectionView.view)
        contentView.addSubview(similarMoviesCollectionView.view)
        contentView.addSubview(socialNetworksCollectionView.view)
        contentView.addSubview(websiteInformation)

        subHeaderStack.addArrangedSubview(releaseDateLabel)
        subHeaderStack.addArrangedSubview(runtimeLabel)

        backdropImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        backdropImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        backdropImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        backdropImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true

        backdropImageHeightAnchor = backdropImage.heightAnchor.constraint(equalToConstant: headerHeight)
        backdropImageHeightAnchor?.isActive = true

        ratingScoreChartView.bottomAnchor.constraint(equalTo: backdropImage.bottomAnchor, constant: 10).isActive = true
        ratingScoreChartView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        ratingScoreChartView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        ratingScoreChartView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        headerStack.topAnchor.constraint(equalTo: backdropImage.bottomAnchor, constant: 10).isActive = true
        headerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true

        subHeaderStack.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 2.5).isActive = true
        subHeaderStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        subHeaderStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        subHeaderStack.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.025).isActive = true

        genresInformation.topAnchor.constraint(equalTo: subHeaderStack.bottomAnchor, constant: 20).isActive = true
        genresInformation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        genresInformation.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        genresInformation.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.125).isActive = true

        overviewLabel.topAnchor.constraint(equalTo: genresInformation.bottomAnchor, constant: 20).isActive = true
        overviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true

        overviewValue.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor).isActive = true
        overviewValue.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        overviewValue.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        overviewValue.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15).isActive = true

        productionCompaniesInformation.topAnchor.constraint(equalTo: overviewValue.bottomAnchor, constant: 20).isActive = true
        productionCompaniesInformation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        productionCompaniesInformation.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        productionCompaniesInformation.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.125).isActive = true

        budgetRevenueInformation.topAnchor.constraint(equalTo: productionCompaniesInformation.bottomAnchor, constant: 20).isActive = true
        budgetRevenueInformation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        budgetRevenueInformation.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        budgetRevenueInformation.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.125).isActive = true

        castCollectionView.view.topAnchor.constraint(equalTo: budgetRevenueInformation.bottomAnchor, constant: 20).isActive = true
        castCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        castCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        castHeightAnchor = castCollectionView.view.heightAnchor.constraint(equalToConstant: view.bounds.height * (UIWindow.isLandscape ? 0.6 : 0.3))
        castHeightAnchor?.isActive = true

        similarMoviesCollectionView.view.topAnchor.constraint(equalTo: castCollectionView.view.bottomAnchor, constant: 20).isActive = true
        similarMoviesCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        similarMoviesCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        similarMoviesHeightAnchor = similarMoviesCollectionView.view.heightAnchor.constraint(equalToConstant: view.bounds.height * (UIWindow.isLandscape ? 0.8 : 0.3))
        similarMoviesHeightAnchor?.isActive = true

        socialNetworksCollectionView.view.topAnchor.constraint(equalTo: similarMoviesCollectionView.view.bottomAnchor, constant: 20).isActive = true
        socialNetworksCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        socialNetworksCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        socialNetworksHeightAnchor = socialNetworksCollectionView.view.heightAnchor.constraint(equalToConstant: view.bounds.height * (UIWindow.isLandscape ? 0.3 : 0.15))
        socialNetworksHeightAnchor?.isActive = true

        websiteInformation.topAnchor.constraint(equalTo: socialNetworksCollectionView.view.bottomAnchor, constant: 20).isActive = true
        websiteInformation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        websiteInformation.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        websiteInformation.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.125).isActive = true
        websiteInformation.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }

    override func setupNavigationBar() {
        super.setupNavigationBar()
        if !pushedViewController {
            let leftBarButtonItemImage = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarButtonItemImage, style: .done, target: self, action: #selector(closeButtonPressed))
        }
    }

    private func handleGestureRecongnizers() {
        let overviewTapGesture = UITapGestureRecognizer(target: self, action: #selector(overviewTapped))
        overviewTapGesture.numberOfTouchesRequired = 1
        overviewValue.addGestureRecognizer(overviewTapGesture)

        let backdropTapGesture = UITapGestureRecognizer(target: self, action: #selector(galleryPressed))
        backdropTapGesture.numberOfTouchesRequired = 1
        backdropImage.addGestureRecognizer(backdropTapGesture)
        backdropImage.isUserInteractionEnabled = true
    }

    override func bindViewModel() {
        movieInfoSubscription = viewModel.outputs.movieInfoAction()
            .sink(receiveValue: { [weak self] (movie) in
                guard let `self` = self else { return }
                self.movie = movie
            })

        socialNetworksSubscription = viewModel.outputs.socialNetworksAction()
            .sink(receiveValue: { [weak self] socialNetworks in
                guard let `self` = self else { return }

                if let socialNetworks = socialNetworks, !(socialNetworks.networks?.isEmpty ?? true) {
                    self.socialNetworksCollectionView.updateCollectionViewData(socialNetworks: socialNetworks)
                } else {
                    self.socialNetworksCollectionView.setupEmptyView()
                }
            })

        castSubscription = viewModel.outputs.creditsAction()
            .sink(receiveValue: { [weak self] credits in
                if let cast = credits?.cast, !cast.isEmpty {
                    self?.castCollectionView.updateCollectionViewData(cast: cast)
                } else {
                    self?.castCollectionView.setupEmptyView()
                }
            })

        similarMoviesSubscription = viewModel.outputs.similarMoviesAction()
            .sink(receiveValue: { [weak self] movies in
                if let movies = movies, !movies.isEmpty {
                    self?.similarMoviesCollectionView.updateCollectionViewData(movies: movies)
                } else {
                    self?.similarMoviesCollectionView.setupEmptyView()
                }
            })
    }

    // MARK: - ⚙️ Helpers
    @objc
    private func closeButtonPressed() {
        viewModel.inputs.closeButtonPressed()
    }

    @objc
    private func galleryPressed() {
        viewModel.inputs.galleryButtonPressed()
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

    @objc
    private func overviewTapped(sender: UIGestureRecognizer) {
        if !overviewValue.text.isEmpty {
            viewModel.inputs.overviewTextPressed()
        }
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑 MovieDetailsVC deinit.")
    }
}

extension MovieDetailsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Title
        if scrollView.convert(headerStack.frame.origin, to: self.view).y <= 60 {
            navigationController?.navigationBar.topItem?.title = movie?.title ?? ""
        } else {
            navigationController?.navigationBar.topItem?.title = ""
        }

        // Backdrop Image effect
        if scrollView.contentOffset.y < 0.0 {
            backdropImageHeightAnchor?.constant = headerHeight - scrollView.contentOffset.y
        } else {
            let parallaxFactor: CGFloat = 0.25
            let offsetY = scrollView.contentOffset.y * parallaxFactor
            let minOffsetY: CGFloat = 8.0
            let availableOffset = min(offsetY, minOffsetY)
            let contentRectOffsetY = availableOffset / headerHeight
            backdropImageHeightAnchor?.constant = (headerHeight - scrollView.contentOffset.y) > 0.0 ? (headerHeight - scrollView.contentOffset.y) : 0.0
            backdropImage.layer.contentsRect = CGRect(x: 0.0, y: -contentRectOffsetY, width: 1.0, height: 1.0)
        }
    }
}
