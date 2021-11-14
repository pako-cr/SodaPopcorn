//
//  PersonGalleryCollectionView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 12/11/21.
//

import UIKit

public final class PersonGalleryCollectionView: UICollectionViewController {
    enum Section: CaseIterable {
        case images
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, PersonImage>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, PersonImage>

    // MARK: - Variables
    private var dataSource: DataSource!
    private var viewModel: PersonDetailsVM?

    // MARK: - UI Elements
    private let collectionLabel = CustomTitleLabelView(titleText: NSLocalizedString("gallery", comment: "Gallery Label"))

    init(viewModel: PersonDetailsVM) {
        self.viewModel = viewModel
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
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(collectionLabel)
        view.addSubview(collectionView)

        collectionLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        collectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        collectionView.topAnchor.constraint(equalTo: collectionLabel.bottomAnchor, constant: 2.0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    // MARK: - Collection
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.register(PersonGalleryCollectionViewCell.self, forCellWithReuseIdentifier: PersonGalleryCollectionViewCell.reuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .clear
    }

    private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .small()

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(1.0))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

            return section
        })
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<PersonGalleryCollectionViewCell, PersonImage> { cell, _, personImage in
            cell.configure(with: personImage)
        }

        let dataSource = UICollectionViewDiffableDataSource<Section, PersonImage>(collectionView: collectionView) { (collectionView, indexPath, personImage) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: personImage)
        }

        self.dataSource = dataSource
    }

    private func setInitialData() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateDataSource(images: [PersonImage]?, animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()

            if let images = images, !images.isEmpty {
                self.collectionView.removeEmptyView()
                snapshot.appendItems(Array(images.prefix(11)), toSection: .images)
                snapshot.appendItems([PersonImage(filePath: "more_info")], toSection: .images)
            }

            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let personImage = dataSource.itemIdentifier(for: indexPath) else { return }

        if personImage.filePath == "more_info" {
            self.viewModel?.inputs.personGallerySelected()
        } else {
            self.viewModel?.inputs.personImageSelected(personImage: personImage)
        }
    }

    // MARK: - ⚙️ Helpers
    func updateCollectionViewData(images: [PersonImage]?) {
        self.updateDataSource(images: images)
    }

    func setupEmptyView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.setEmptyView(title: "", message: NSLocalizedString("no_information", comment: "No information"), centeredX: false)
        }
    }
}
