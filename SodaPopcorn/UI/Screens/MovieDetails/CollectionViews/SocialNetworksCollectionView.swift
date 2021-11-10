//
//  SocialNetworksCollectionView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 7/11/21.
//

import UIKit

public final class SocialNetworksCollectionView: UICollectionViewController {
    enum Section: CaseIterable {
        case socialNetworks
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, SocialNetwork>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SocialNetwork>

    // MARK: - Variables
    private var dataSource: DataSource!
    private var movieDetailsVM: MovieDetailsVM?

    // MARK: - UI Elements
    private let collectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.text = NSLocalizedString("movie_details_vc_homepage_label", comment: "Homepage label")
        label.sizeToFit()
        label.isHidden = true
        return label
    }()

    private lazy var websiteUrlButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(openMovieWebsite), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(UIColor.gray, for: .normal)
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.maximumContentSizeCategory = .accessibilityMedium
        button.sizeToFit()
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        return button
    }()

    init(movieDetailsVM: MovieDetailsVM) {
        self.movieDetailsVM = movieDetailsVM
        super.init(collectionViewLayout: UICollectionViewLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        configureCollectionView()
        configureDataSource()
        setInitialData()
        setupUI()
    }

    func setupUI() {
        view.addSubview(collectionView)
        view.addSubview(collectionLabel)
        view.addSubview(websiteUrlButton)

        collectionLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true

        websiteUrlButton.topAnchor.constraint(equalTo: collectionLabel.bottomAnchor, constant: 10.0).isActive = true
        websiteUrlButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        websiteUrlButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        websiteUrlButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true

        collectionView.topAnchor.constraint(equalTo: websiteUrlButton.bottomAnchor, constant: 10.0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    // MARK: - ⚙️ Helpers
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.register(SocialNetworksCollectionViewCell.self, forCellWithReuseIdentifier: SocialNetworksCollectionViewCell.reuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
    }

    private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33333), heightDimension: .fractionalHeight(1.0))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(60.0))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            return section
        })
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<SocialNetworksCollectionViewCell, SocialNetwork> { cell, _, socialNetwork in
            cell.configure(with: socialNetwork)
        }

        let dataSource = UICollectionViewDiffableDataSource<Section, SocialNetwork>(collectionView: collectionView) { (collectionView, indexPath, imageURL) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: imageURL)
        }

        self.dataSource = dataSource
    }

    private func setInitialData() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateDataSource(socialNetworks: [SocialNetwork]?, animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()

            if let socialNetworks = socialNetworks, !socialNetworks.isEmpty {
                self.collectionLabel.isHidden = false
                snapshot.appendItems(socialNetworks, toSection: .socialNetworks)
            }

            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    func updateCollectionViewData(socialNetworks: SocialNetworks) {
        self.updateDataSource(socialNetworks: socialNetworks.networks)
    }

    private func openSocialNetwork(socialNetwork: SocialNetwork) {
        var homeUrl = ""

        switch socialNetwork {
        case .instagram(let userId):
            homeUrl = "https://www.instagram.com/\(userId)"
        case .facebook(let userId):
            homeUrl = "https://www.facebook.com/\(userId)"
        case .twitter(let userId):
            homeUrl = "https://www.twitter.com/\(userId)"
        }

        if let url = URL(string: homeUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let socialNetwork = dataSource.itemIdentifier(for: indexPath) else { return }
        self.openSocialNetwork(socialNetwork: socialNetwork)
    }

    func setWebsiteUrl(url: String?) {
        if let url = url, !url.isEmpty {
            self.collectionLabel.isHidden = false
            self.websiteUrlButton.setTitle(url, for: .normal)
            self.websiteUrlButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body).italic()
            self.websiteUrlButton.setTitleColor(UIColor.systemBlue, for: .normal)
        }
    }

    @objc func openMovieWebsite() {
        if let websiteUrl = self.websiteUrlButton.titleLabel?.text, !websiteUrl.isEmpty,
           !websiteUrl.elementsEqual(NSLocalizedString("not_applicable", comment: "Not applicable")),
           let url = URL(string: websiteUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
