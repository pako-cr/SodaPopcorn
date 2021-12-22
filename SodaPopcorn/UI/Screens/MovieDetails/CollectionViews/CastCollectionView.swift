//
//  CastCollectionView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 10/11/21.
//

import Domain
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
    private var viewModel: MovieDetailsVM?

    // MARK: - UI Elements
    private let collectionLabel = CustomTitleLabelView(titleText: NSLocalizedString("cast_collection_view_title", comment: "Cast Label"))

    init(viewModel: MovieDetailsVM) {
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
        collectionView.register(CastCollectionViewCell.self, forCellWithReuseIdentifier: CastCollectionViewCell.reuseIdentifier)
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
            section.orthogonalScrollingBehavior = .groupPagingCentered

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
                self.collectionView.removeEmptyView()
                snapshot.appendItems(Array(cast.prefix(11)), toSection: .cast)
                snapshot.appendItems([Cast(name: "more_info")], toSection: .cast)
            }

            self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }

    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cast = dataSource.itemIdentifier(for: indexPath) else { return }

        if cast.name == "more_info" {
            self.viewModel?.inputs.creditsButtonPressed()
        } else {
            self.viewModel?.inputs.castMemberSelected(cast: cast)
        }
    }

    func setupEmptyView() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.collectionView.setEmptyView(title: "", message: NSLocalizedString("no_information", comment: "No information"), centeredX: false)
        }
    }

    // MARK: - ⚙️ Helpers
    func updateCollectionViewData(cast: [Cast]) {
        self.updateDataSource(cast: cast)
    }
}
