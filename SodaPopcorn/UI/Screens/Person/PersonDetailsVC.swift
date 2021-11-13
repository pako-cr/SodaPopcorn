//
//  PersonDetailsVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

import Combine
import UIKit

final class PersonDetailsVC: BaseViewController {
    // MARK: Consts
    private let viewModel: PersonDetailsVM

    // MARK: - Variables
    private var personInfoSubscription: Cancellable!
    private var moviesSubscription: Cancellable!
    private var imagesSubscription: Cancellable!
    private var socialNetworksSubscription: Cancellable!

    private var person: Person? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let person = self.person else { return }

                // Poster
                if let posterImageUrl = person.profilePath {
                    self.posterImage.setUrlString(urlString: posterImageUrl)
                }

                // Title
                if let personName = person.name, !personName.isEmpty {
                    self.personNameLabel.text = personName
                }

                // Birthday
                if let birthday = person.birthday, !birthday.isEmpty {
                    self.birthdayValue.text = birthday

                    if let personAge = self.calculatePersonAge(birthday: birthday) {
                        let yearsOld = String(format: NSLocalizedString("person_years_old", comment: "Person age"), personAge.description)
                        self.birthdayValue.text?.append(yearsOld)
                    }
                }

                // Place of birth
                if let placeOfBirth = person.placeOfBirth, !placeOfBirth.isEmpty {
                    self.placeOfBirthValue.text = placeOfBirth
                }

                // Biography
                if let biography = person.biography, !biography.isEmpty {
                    self.biographyValue.text = biography
                }

                // Website
                if let website = person.homepage {
                    self.websiteInformation.setSubheaderValue(subheader: website)
                    self.websiteInformation.isUserInteractionEnabled = true
                }
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

    private let posterImage = CustomPosterImage(frame: .zero)

    private let headerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let personNameLabel: UILabel = {
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

    private let birthdayLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .headline).bold()
        label.textAlignment = .natural
        label.maximumContentSizeCategory = .accessibilityMedium
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.text = NSLocalizedString("birthdate", comment: "Not applicable")
        label.textColor = UIColor.darkGray
        label.sizeToFit()
        return label
    }()

    private let birthdayValue: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.sizeToFit()
        label.text = NSLocalizedString("not_applicable", comment: "Not applicable")
        return label
    }()

    private let placeOfBirthLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .headline).bold()
        label.textAlignment = .natural
        label.maximumContentSizeCategory = .accessibilityMedium
        label.adjustsFontForContentSizeCategory = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.text = NSLocalizedString("place_of_birth", comment: "Not applicable")
        label.textColor = UIColor.darkGray
        label.sizeToFit()
        return label
    }()

    private let placeOfBirthValue: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textAlignment = .natural
        label.adjustsFontSizeToFitWidth = true
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.sizeToFit()
        label.text = NSLocalizedString("not_applicable", comment: "Not applicable")
        return label
    }()

    private let biographyLabel = CustomTitleLabelView(titleText: NSLocalizedString("biography", comment: "Overview Label"))

    private let biographyValue = CustomTextView(customText: NSLocalizedString("no_biography_found", comment: "No biograpghy"))

    private lazy var personGalleryCollectionView = PersonGalleryCollectionView(viewModel: self.viewModel)

    private lazy var knownForCollectionView = KnownForCollectionView(viewModel: self.viewModel)

    private let socialNetworksCollectionView = SocialNetworksCollectionView()

    private let websiteInformation = CustomHeaderSubheaderView(header: NSLocalizedString("website", comment: "Website"))

    init(viewModel: PersonDetailsVM) {
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

        headerStack.addArrangedSubview(personNameLabel)
        headerStack.addArrangedSubview(birthdayLabel)
        headerStack.addArrangedSubview(birthdayValue)
        headerStack.addArrangedSubview(placeOfBirthLabel)
        headerStack.addArrangedSubview(placeOfBirthValue)

        contentView.addSubview(posterImage)
        contentView.addSubview(headerStack)
        contentView.addSubview(biographyLabel)
        contentView.addSubview(biographyValue)
        contentView.addSubview(personGalleryCollectionView.view)
        contentView.addSubview(knownForCollectionView.view)
        contentView.addSubview(socialNetworksCollectionView.view)
        contentView.addSubview(websiteInformation)

        posterImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        posterImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        posterImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3333).isActive = true
        posterImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true

        headerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        headerStack.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 10).isActive = true
        headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        headerStack.bottomAnchor.constraint(equalTo: posterImage.bottomAnchor, constant: 0).isActive = true

        biographyLabel.topAnchor.constraint(equalTo: posterImage.bottomAnchor, constant: 20).isActive = true
        biographyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        biographyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true

        biographyValue.topAnchor.constraint(equalTo: biographyLabel.bottomAnchor).isActive = true
        biographyValue.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        biographyValue.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        biographyValue.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25).isActive = true

        personGalleryCollectionView.view.topAnchor.constraint(equalTo: biographyValue.bottomAnchor, constant: 20).isActive = true
        personGalleryCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        personGalleryCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        personGalleryCollectionView.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true

        knownForCollectionView.view.topAnchor.constraint(equalTo: personGalleryCollectionView.view.bottomAnchor, constant: 20).isActive = true
        knownForCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        knownForCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        knownForCollectionView.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35).isActive = true

        socialNetworksCollectionView.view.topAnchor.constraint(equalTo: knownForCollectionView.view.bottomAnchor, constant: 20).isActive = true
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
        let leftBarButtonItemImage = UIImage(systemName: "arrow.backward")?.withRenderingMode(.alwaysTemplate)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarButtonItemImage, style: .done, target: self, action: #selector(closeButtonPressed))

        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryColor")
    }

    private func handleGestureRecongnizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(biographyTapped))
        tapGesture.numberOfTouchesRequired = 1
        biographyValue.addGestureRecognizer(tapGesture)
    }

    override func bindViewModel() {
        personInfoSubscription = viewModel.outputs.personInfoAction()
            .sink(receiveValue: { [weak self] (person) in
                guard let `self` = self else { return }
                self.person = person
            })

        moviesSubscription = viewModel.outputs.fetchPersonMoviesAction()
            .sink(receiveValue: { [weak self] movies in
                if !movies.isEmpty {
                    self?.knownForCollectionView.updateCollectionViewData(movies: movies)
                } else {
                    self?.knownForCollectionView.setupEmptyView()
                }
            })

        imagesSubscription = viewModel.outputs.personImagesAction()
            .sink(receiveValue: { [weak self] personImages in
                guard let `self` = self else { return }
                if let images = personImages {
                    self.personGalleryCollectionView.updateCollectionViewData(images: images)
                } else {
                    self.personGalleryCollectionView.setupEmptyView()
                }

            })

        socialNetworksSubscription = viewModel.outputs.socialNetworksAction()
            .sink(receiveValue: { [weak self] socialNetworks in
                if let socialNetworks = socialNetworks, !(socialNetworks.networks?.isEmpty ?? true) {
                    self?.socialNetworksCollectionView.updateCollectionViewData(socialNetworks: socialNetworks)

                } else {
                    self?.socialNetworksCollectionView.setupEmptyView()
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
//        viewModel.inputs.galleryButtonPressed()
    }

    @objc
    private func biographyTapped(sender: UIGestureRecognizer) {
        if !biographyValue.text.isEmpty {
            viewModel.inputs.biographyTextPressed()
        }
    }

    private func calculatePersonAge(birthday: String) -> Int? {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy/MM/dd"

        if let birthdayDate = dateFormater.date(from: birthday) {
            let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
            let now = Date()
            let calcAge = calendar.components(.year, from: birthdayDate, to: now, options: [])
            return calcAge.year
        }
        return nil
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑 PersonDetailsVC deinit.")
    }
}

extension PersonDetailsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.convert(headerStack.frame.origin, to: self.view).y <= 60 {
            navigationController?.navigationBar.topItem?.title = person?.name ?? ""
        } else {
            navigationController?.navigationBar.topItem?.title = ""
        }
    }
}
