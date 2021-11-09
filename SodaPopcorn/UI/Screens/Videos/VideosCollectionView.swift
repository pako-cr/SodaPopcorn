//
//  VideosCollectionView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

import UIKit

final class VideosCollectionView: CompositionalCollectionViewBaseVC {
    enum Section: CaseIterable {
        case videos
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>

    // MARK: - Variables
    private var dataSource: DataSource!
    private var movieDetailsVM: MovieDetailsVM?

    init(movieDetailsVM: MovieDetailsVM) {
        self.movieDetailsVM = movieDetailsVM
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        configureDataSource()
        setInitialData()
    }

    override func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [unowned self] index, environment in
            return self.layoutSection(forIndex: index, environment: environment)
        }
    }

    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<BackdropCollectionViewCell, String> { cell, _, imageURL in
            cell.configure(with: imageURL)
        }

        let dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView) { (collectionView, indexPath, imageURL) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: imageURL)
        }

        self.dataSource = dataSource
    }

    private func layoutSection(forIndex index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalHeight(1.0))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        return section
    }

    // MARK: - ⚙️ Helpers
    private func setInitialData() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateDataSource(images: [String], animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()

            snapshot.appendItems(images, toSection: .videos)

            print("🔸 Images Snapshot items: \(snapshot.numberOfItems)")
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    func updateCollectionViewData(images: [String]) {
        self.updateDataSource(images: images)
    }
}

/*
extension VideosCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }
//        viewModel.inputs.movieSelected(movie: movie)
    }
}
*/
