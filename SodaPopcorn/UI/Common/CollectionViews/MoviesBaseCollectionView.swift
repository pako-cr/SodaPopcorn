//
//  MoviesBaseCollectionView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 16/11/21.
//

import Foundation
import UIKit

class MoviesBaseCollectionView: UIViewController {
    enum Section: CaseIterable {
        case movies
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>

    // MARK: - Variables
    var collectionView: UICollectionView!
    var dataSource: DataSource!
    var loadedCount = 0

    var reloadingDataSource = false

    var collectionLayout: CollectionLayout = .columns {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                // 􀭞 : square.fill.text.grid.1x2
                // 􀮞 : squareshape.split.2x2
                // 􀏟: rectangle.split.3x1

                var buttonImage: UIImage?
                switch self.collectionLayout {
                case .list:
                    buttonImage = UIImage(systemName: "rectangle.split.3x1")
                case .columns:
                    buttonImage = UIImage(systemName: "square.fill.text.grid.1x2")
                }

                self.navigationItem.leftBarButtonItem?.image = buttonImage
                self.collectionView.setCollectionViewLayout(self.createLayout(), animated: true)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureCollectionView()
        configureDataSource()
        setInitialData()

        view.backgroundColor = .systemBackground

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.reuseIdentifier)
        collectionView.register(ActivityIndicatorFooterReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: ActivityIndicatorFooterReusableView.reuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.isPrefetchingEnabled = true
        collectionView.alwaysBounceVertical = true
    }

    func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (_, _) -> NSCollectionLayoutSection? in
            guard let `self` = self else { return nil }

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth( (self.collectionLayout == .columns && UIWindow.isLandscape) ? 0.25 : self.collectionLayout.rawValue),
                                                  heightDimension: .fractionalHeight(1.0))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets.uniform(size: 2.0)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(UIScreen.main.bounds.height / (UIWindow.isLandscape ? 1.5 : 3.75)))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            // Supplementary footer view setup
            let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50))

            let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom)

            sectionFooter.contentInsets = .small()

            section.boundarySupplementaryItems = [sectionFooter]

            return section
        })
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MovieCollectionViewCell, Movie> { cell, _, movie in
            cell.configure(with: movie)
        }

        let dataSource = UICollectionViewDiffableDataSource<Section, Movie>(collectionView: collectionView) { (collectionView, indexPath, movie) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter else { return nil }

            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ActivityIndicatorFooterReusableView.reuseIdentifier, for: indexPath) as? ActivityIndicatorFooterReusableView
        }

        self.dataSource = dataSource
    }

    func setInitialData() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        self.dataSource.apply(snapshot, animatingDifferences: false)
        self.handleEmptyView()
    }

    func reloadDataSource() {
        self.reloadingDataSource = false
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(Section.allCases)

        self.dataSource.apply(snapshot, animatingDifferences: true)
        cache.removeAllValues()
    }

    func updateDataSource(movies: [Movie], animatingDifferences: Bool = true) {
        preconditionFailure("Override updateDataSource() to update the datasource")
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        preconditionFailure("Override willDisplay")
    }

    func handleEmptyView() {
        preconditionFailure("Override handleEmptyView() to provide an empty view for the collection view")
    }
}
