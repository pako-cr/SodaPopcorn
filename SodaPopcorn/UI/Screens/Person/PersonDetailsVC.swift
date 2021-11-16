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

    // MARK: Constraints
    private var profileImageHeightAnchor: NSLayoutConstraint?
    private var galleryCollectionViewHeightAnchor: NSLayoutConstraint?
    private var knownForCollectionViewHeightAnchor: NSLayoutConstraint?
    private var socialNetworksHeightAnchor: NSLayoutConstraint?

    private var person: Person? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, let person = self.person else { return }

                // Poster
                if let posterImageUrl = person.profilePath {
                    self.profileImage.setUrlString(urlString: posterImageUrl)
                }

                // Title
                if let personName = person.name, !personName.isEmpty {
                    self.personNameLabel.text = personName
                }

                // Birthday
                if let birthdate = person.birthday, !birthdate.isEmpty {
                    var birthdateString = birthdate

                    if let personAge = self.calculatePersonAge(birthday: birthdate) {
                        let yearsOld = String(format: NSLocalizedString("person_years_old", comment: "Person age"), personAge.description)
                        birthdateString.append(yearsOld)

                    }

                    self.birthdateHeaderValue.setValue(value: birthdateString)
                }

                // Place of birth
                if let placeOfBirth = person.placeOfBirth, !placeOfBirth.isEmpty {
                    self.placeOfBirthHeaderValue.setValue(value: placeOfBirth)
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

    private let profileImage = CustomProfileImage(frame: .zero)

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
        label.text = NSLocalizedString("no_information", comment: "No information")
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let birthdateHeaderValue = CustomPersonHeaderValueView(header: NSLocalizedString("birthdate", comment: "Birthdate label"))

    private let placeOfBirthHeaderValue = CustomPersonHeaderValueView(header: NSLocalizedString("place_of_birth", comment: "Place of birth"))

    private let biographyLabel = CustomTitleLabelView(titleText: NSLocalizedString("biography", comment: "Overview Label"))

    private let biographyValue = CustomTextView(customText: NSLocalizedString("no_information", comment: "No information"))

    private lazy var galleryCollectionView = PersonGalleryCollectionView(viewModel: self.viewModel)

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

        profileImageHeightAnchor?.constant = view.bounds.height * (UIWindow.isLandscape ? 0.65 : 0.3)
        galleryCollectionViewHeightAnchor?.constant = view.bounds.height * (UIWindow.isLandscape ? 0.6 : 0.3)
        knownForCollectionViewHeightAnchor?.constant = view.bounds.height * (UIWindow.isLandscape ? 0.8 : 0.35)
        socialNetworksHeightAnchor?.constant = view.bounds.height * (UIWindow.isLandscape ? 0.3 : 0.15)
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
        headerStack.addArrangedSubview(birthdateHeaderValue)
        headerStack.addArrangedSubview(placeOfBirthHeaderValue)

        contentView.addSubview(profileImage)
        contentView.addSubview(headerStack)
        contentView.addSubview(biographyLabel)
        contentView.addSubview(biographyValue)
        contentView.addSubview(galleryCollectionView.view)
        contentView.addSubview(knownForCollectionView.view)
        contentView.addSubview(socialNetworksCollectionView.view)
        contentView.addSubview(websiteInformation)

        profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        profileImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3333).isActive = true
        profileImageHeightAnchor = profileImage.heightAnchor.constraint(equalToConstant: view.bounds.height * (UIWindow.isLandscape ? 0.65 : 0.3))
        profileImageHeightAnchor?.isActive = true

        headerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        headerStack.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 10).isActive = true
        headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        headerStack.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 0).isActive = true

        biographyLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 20).isActive = true
        biographyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        biographyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true

        biographyValue.topAnchor.constraint(equalTo: biographyLabel.bottomAnchor).isActive = true
        biographyValue.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        biographyValue.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        biographyValue.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25).isActive = true

        galleryCollectionView.view.topAnchor.constraint(equalTo: biographyValue.bottomAnchor, constant: 20).isActive = true
        galleryCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        galleryCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        galleryCollectionViewHeightAnchor = galleryCollectionView.view.heightAnchor.constraint(equalToConstant: view.bounds.height * (UIWindow.isLandscape ? 0.6 : 0.3))
        galleryCollectionViewHeightAnchor?.isActive = true

        knownForCollectionView.view.topAnchor.constraint(equalTo: galleryCollectionView.view.bottomAnchor, constant: 20).isActive = true
        knownForCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        knownForCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        knownForCollectionViewHeightAnchor = knownForCollectionView.view.heightAnchor.constraint(equalToConstant: view.bounds.height * (UIWindow.isLandscape ? 0.8 : 0.35))
        knownForCollectionViewHeightAnchor?.isActive = true

        socialNetworksCollectionView.view.topAnchor.constraint(equalTo: knownForCollectionView.view.bottomAnchor, constant: 20).isActive = true
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
                if let images = personImages, !images.isEmpty {
                    self.galleryCollectionView.updateCollectionViewData(images: images)
                } else {
                    self.galleryCollectionView.setupEmptyView()
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
