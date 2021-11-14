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
    private var castSubscription: Cancellable!

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
                    self.ratingLabel.text = "﹒ \(movie.rating ?? 0.0)/10 ⭐️"
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

    private let backdropImage = CustomBackdropImage(frame: .zero)

    private let galleryButton = CustomButton(buttonTitle: NSLocalizedString("gallery", comment: "Gallery button"))

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

    private let genresInformation = CustomHeaderSubheaderView(header: NSLocalizedString("movie_details_vc_genre_label", comment: "Genre Label"))

    private let overviewLabel = CustomTitleLabelView(titleText: NSLocalizedString("movie_details_vc_overview_label", comment: "Overview Label"))

    private let overviewValue = CustomTextView(customText: NSLocalizedString("movie_details_vc_no_overview_found", comment: "No overview"))

    private let productionCompaniesInformation = CustomHeaderSubheaderView(header: NSLocalizedString("movie_details_vc_production_companies_label", comment: "Production companies label"))

    private let budgetRevenueInformation = CustomHeaderSubheaderView(header: NSLocalizedString("movie_details_vc_budget_revenue_label", comment: "Budget/revenue label"))

    private lazy var castCollectionView = CastCollectionView(movieDetailsVM: self.viewModel)

    private let socialNetworksCollectionView = SocialNetworksCollectionView()

    private let websiteInformation = CustomHeaderSubheaderView(header: NSLocalizedString("website", comment: "Website"))

    init(viewModel: MovieDetailsVM) {
        self.viewModel = viewModel
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

        contentView.addSubview(backdropImage)
        contentView.addSubview(galleryButton)
        contentView.addSubview(headerStack)
        contentView.addSubview(subHeaderStack)
        contentView.addSubview(genresInformation)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(overviewValue)
        contentView.addSubview(productionCompaniesInformation)
        contentView.addSubview(budgetRevenueInformation)
        contentView.addSubview(castCollectionView.view)
        contentView.addSubview(socialNetworksCollectionView.view)
        contentView.addSubview(websiteInformation)

        subHeaderStack.addArrangedSubview(releaseDateLabel)
        subHeaderStack.addArrangedSubview(runtimeLabel)
        subHeaderStack.addArrangedSubview(ratingLabel)

        backdropImage.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        backdropImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        backdropImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        backdropImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        backdropImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true

        galleryButton.bottomAnchor.constraint(equalTo: backdropImage.bottomAnchor, constant: -10).isActive = true
        galleryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        galleryButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        galleryButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

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
        genresInformation.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true

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
        productionCompaniesInformation.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true

        budgetRevenueInformation.topAnchor.constraint(equalTo: productionCompaniesInformation.bottomAnchor, constant: 20).isActive = true
        budgetRevenueInformation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        budgetRevenueInformation.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        budgetRevenueInformation.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true

        castCollectionView.view.topAnchor.constraint(equalTo: budgetRevenueInformation.bottomAnchor, constant: 20).isActive = true
        castCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        castCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        castCollectionView.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true

        socialNetworksCollectionView.view.topAnchor.constraint(equalTo: castCollectionView.view.bottomAnchor, constant: 20).isActive = true
        socialNetworksCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        socialNetworksCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        socialNetworksCollectionView.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.15).isActive = true

        websiteInformation.topAnchor.constraint(equalTo: socialNetworksCollectionView.view.bottomAnchor, constant: 20).isActive = true
        websiteInformation.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        websiteInformation.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        websiteInformation.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
        websiteInformation.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }

    private func setupNavigationBar() {
        let leftBarButtonItemImage = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarButtonItemImage, style: .done, target: self, action: #selector(closeButtonPressed))

        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryColor")
    }

    private func handleGestureRecongnizers() {
        let overviewTapGesture = UITapGestureRecognizer(target: self, action: #selector(overviewTapped))
        overviewTapGesture.numberOfTouchesRequired = 1
        overviewValue.addGestureRecognizer(overviewTapGesture)

        let backdropTapGesture = UITapGestureRecognizer(target: self, action: #selector(galleryButtonPressed))
        backdropTapGesture.numberOfTouchesRequired = 1
        backdropImage.addGestureRecognizer(backdropTapGesture)
        backdropImage.isUserInteractionEnabled = true

        galleryButton.addTarget(self, action: #selector(galleryButtonPressed), for: .touchUpInside)
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
        if scrollView.convert(headerStack.frame.origin, to: self.view).y <= 60 {
            navigationController?.navigationBar.topItem?.title = movie?.title ?? ""
        } else {
            navigationController?.navigationBar.topItem?.title = ""
        }
    }
}
