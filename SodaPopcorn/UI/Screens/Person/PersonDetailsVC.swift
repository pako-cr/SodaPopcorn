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
                self.socialNetworksCollectionView.setWebsiteUrl(url: person.homepage)
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

    private let posterImage = CustomPosterImage(frame: .zero)

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

    private let biographyLabel: UILabel = {
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

    private let biographyValue: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.preferredFont(forTextStyle: .body).italic()
        textView.textAlignment = .natural
        textView.isSelectable = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        textView.text = NSLocalizedString("no_biography_found", comment: "No biograpghy")
        textView.sizeToFit()
        textView.adjustsFontForContentSizeCategory = true
        textView.maximumContentSizeCategory = .accessibilityMedium
        textView.textContainer.lineBreakMode = .byTruncatingTail
        return textView
    }()

    private lazy var knownForCollectionView = KnownForCollectionView(personDetailsVM: self.viewModel)

    private let socialNetworksCollectionView = SocialNetworksCollectionView()

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
        contentView.addSubview(closeButton)
        contentView.addSubview(headerStack)
        contentView.addSubview(biographyLabel)
        contentView.addSubview(biographyValue)
        contentView.addSubview(knownForCollectionView.view)
        contentView.addSubview(socialNetworksCollectionView.view)

        closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        posterImage.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 2).isActive = true
        posterImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        posterImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.3333).isActive = true
        posterImage.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true

        headerStack.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 2).isActive = true
        headerStack.leadingAnchor.constraint(equalTo: posterImage.trailingAnchor, constant: 10).isActive = true
        headerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        headerStack.bottomAnchor.constraint(equalTo: posterImage.bottomAnchor, constant: 0).isActive = true

        biographyLabel.topAnchor.constraint(equalTo: posterImage.bottomAnchor, constant: 20).isActive = true
        biographyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        biographyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        biographyLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.05).isActive = true

        biographyValue.topAnchor.constraint(equalTo: biographyLabel.bottomAnchor).isActive = true
        biographyValue.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        biographyValue.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        biographyValue.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true

        knownForCollectionView.view.topAnchor.constraint(equalTo: biographyValue.bottomAnchor, constant: 20).isActive = true
        knownForCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        knownForCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        knownForCollectionView.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true

        socialNetworksCollectionView.view.topAnchor.constraint(equalTo: knownForCollectionView.view.bottomAnchor, constant: 20).isActive = true
        socialNetworksCollectionView.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        socialNetworksCollectionView.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        socialNetworksCollectionView.view.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25).isActive = true
        socialNetworksCollectionView.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
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
                self?.knownForCollectionView.updateCollectionViewData(movies: movies)
            })

//        imagesSubscription = viewModel.outputs.backdropImagesAction()
//            .sink(receiveValue: { [weak self] backdropImages in
//                guard let `self` = self else { return }
//                let backdrops = backdropImages.map({ $0.filePath ?? ""})
//                self.backdropCollectionView.updateCollectionViewData(images: backdrops)
//            })

        socialNetworksSubscription = viewModel.outputs.socialNetworksAction()
            .sink(receiveValue: { [weak self] socialNetworks in
                self?.socialNetworksCollectionView.updateCollectionViewData(socialNetworks: socialNetworks)
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
