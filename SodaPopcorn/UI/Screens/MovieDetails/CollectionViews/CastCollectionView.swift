//
//  CastCollectionView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 10/11/21.
//

import UIKit

public final class CastCollectionView: UICollectionViewController {
    enum Section: CaseIterable {
        case cast
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Cast>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cast>

    // MARK: - Variables
    private var dataSource: DataSource!
    private var movieDetailsVM: MovieDetailsVM?

    // MARK: - UI Elements
    private let collectionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .title3).bold()
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.text = NSLocalizedString("cast_collection_view_title", comment: "Cast Label")
        label.sizeToFit()
        return label
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
        view.addSubview(collectionLabel)
        view.addSubview(collectionView)

        collectionLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2).isActive = true

        collectionView.topAnchor.constraint(equalTo: collectionLabel.bottomAnchor, constant: 2.0).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    // MARK: - ⚙️ Helpers
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.register(CastCollectionViewCell.self, forCellWithReuseIdentifier: CastCollectionViewCell.reuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = true
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
        let cellRegistration = UICollectionView.CellRegistration<CastCollectionViewCell, Cast> { cell, _, cast in
            cell.configure(with: cast)
        }

        let dataSource = UICollectionViewDiffableDataSource<Section, Cast>(collectionView: collectionView) { (collectionView, indexPath, imageURL) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: imageURL)
        }

        self.dataSource = dataSource
    }

    private func setInitialData() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateDataSource(cast: [Cast], animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()

            if !cast.isEmpty {
                snapshot.appendItems(cast, toSection: .cast)
            } else {
                snapshot.appendItems([Cast()], toSection: .cast)
            }

            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    func updateCollectionViewData(cast: [Cast]) {
        self.updateDataSource(cast: cast)
    }

    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cast = dataSource.itemIdentifier(for: indexPath) else { return }
        print(cast.name ?? "")
    }
}
