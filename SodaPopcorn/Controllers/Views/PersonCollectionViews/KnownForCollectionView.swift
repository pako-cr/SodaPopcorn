//
//  KnownForCollectionView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

import UIKit

public final class KnownForCollectionView: UICollectionViewController {
    enum Section: CaseIterable {
        case movies
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>

    // MARK: - Variables
    private var dataSource: DataSource!
    private var viewModel: PersonDetailsVM?

    // MARK: - UI Elements
    private let collectionLabel = CustomTitleLabelView(titleText: NSLocalizedString("known_for_collection_view_title", comment: "Know for label"))

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
        collectionView.register(KnownForCollectionViewCell.self, forCellWithReuseIdentifier: KnownForCollectionViewCell.reuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .clear
    }

    private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(UIDevice.isLandscape ? 0.25 : 0.3333), heightDimension: .fractionalHeight(1.0))

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
        let cellRegistration = UICollectionView.CellRegistration<KnownForCollectionViewCell, Movie> { cell, _, movie in
            cell.configure(with: movie)
        }

        let dataSource = UICollectionViewDiffableDataSource<Section, Movie>(collectionView: collectionView) { (collectionView, indexPath, movie) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
        }

        self.dataSource = dataSource
    }

    private func setInitialData() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateDataSource(movies: [Movie], animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()

            if !movies.isEmpty {
                self.collectionView.removeEmptyView()
                snapshot.appendItems(Array(movies.prefix(11)), toSection: .movies)
                snapshot.appendItems([Movie(id: "", movieTitle: "more_info")], toSection: .movies)
            }

            self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }

    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }

        if movie.movieTitle == "more_info" {
            self.viewModel?.inputs.personMoviesButtonPressed()
        } else {
            self.viewModel?.inputs.movieSelected(movie: movie)
        }
    }

    // MARK: - ⚙️ Helpers
    func updateCollectionViewData(movies: [Movie]) {
        self.updateDataSource(movies: movies)
    }

    func setupEmptyView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.setEmptyView(title: "", message: NSLocalizedString("no_information", comment: "No information"), centeredX: false)
        }
    }
}
