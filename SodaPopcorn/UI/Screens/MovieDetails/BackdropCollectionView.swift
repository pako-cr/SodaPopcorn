//
//  BackdropCollectionView.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

import UIKit

public final class BackdropCollectionView: UICollectionViewController {
    enum Section: CaseIterable {
        case images
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>

    // MARK: - Variables
    private var dataSource: DataSource!
    private var movieDetailsVM: MovieDetailsVM?

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

        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    public override func viewWillLayoutSubviews() {
        collectionView.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    // MARK: - ⚙️ Helpers
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.register(BackdropCollectionViewCell.self, forCellWithReuseIdentifier: BackdropCollectionViewCell.reuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = false
    }

    private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            section.orthogonalScrollingBehavior = .groupPagingCentered

            return section
        })
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

    private func setInitialData() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateDataSource(images: [String], animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()

            snapshot.appendItems(images, toSection: .images)

            print("🔸 Images Snapshot items: \(snapshot.numberOfItems)")
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    func updateCollectionViewData(images: [String]) {
        self.updateDataSource(images: images)
    }

    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let imageURL = dataSource.itemIdentifier(for: indexPath) else { return }
        movieDetailsVM?.inputs.backdropImageSelected(imageURL: imageURL)
    }
}
