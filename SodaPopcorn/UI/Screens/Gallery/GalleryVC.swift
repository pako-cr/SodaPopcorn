//
//  GalleryVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

import Combine
import UIKit

final class GalleryVC: BaseViewController {
    enum Section: CaseIterable {
        case backdrops
        case posters
        case videos
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>

    // MARK: Consts
    private let viewModel: GalleryVM

    // MARK: - Variables
    private var dataSource: DataSource!
    private var fetchGallerySubscription: Cancellable!
    private var loadingSubscription: Cancellable!
    private var showErrorSubscription: Cancellable!

    // MARK: UI Elements
    private var customCollectionView: UICollectionView!

    init(viewModel: GalleryVM) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        configureCollectionView()
        configureDataSource()
        setInitialData()
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad()
        setupNavigationBar()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
        customCollectionView.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    override func setupUI() {
        view.addSubview(customCollectionView)

        customCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        customCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        customCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func setupNavigationBar() {
        let leftBarButtonItemImage = UIImage(systemName: "arrow.backward")?.withRenderingMode(.alwaysTemplate)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarButtonItemImage, style: .done, target: self, action: #selector(closeButtonPressed))

        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryColor")

        title = NSLocalizedString("gallery", comment: "Gallery")
    }

    override func bindViewModel() {
        fetchGallerySubscription = viewModel.outputs.galleryAction()
            .sink(receiveValue: { [weak self] gallery in
                guard let `self` = self else { return }
                self.updateDataSource(gallery: gallery)
            })
    }

    // MARK: - Collection
    private func configureCollectionView() {
        customCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        customCollectionView.register(BackdropCollectionViewCell.self, forCellWithReuseIdentifier: BackdropCollectionViewCell.reuseIdentifier)
        customCollectionView.register(PosterCollectionViewCell.self, forCellWithReuseIdentifier: PosterCollectionViewCell.reuseIdentifier)
        customCollectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.reuseIdentifier)
        customCollectionView.register(GalleryHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: GalleryHeaderReusableView.reuseIdentifier)
        customCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
        customCollectionView.translatesAutoresizingMaskIntoConstraints = false
        customCollectionView.isScrollEnabled = true
        customCollectionView.showsVerticalScrollIndicator = false
        customCollectionView.allowsSelection = true
        customCollectionView.isPrefetchingEnabled = true
        customCollectionView.delegate = self
        customCollectionView.alwaysBounceVertical = true
        customCollectionView.backgroundColor = UIColor.systemBackground
    }

    private func configureDataSource() {
        self.dataSource = DataSource(collectionView: customCollectionView, cellProvider: { collectionView, indexPath, item in
            switch indexPath.section {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BackdropCollectionViewCell.reuseIdentifier, for: indexPath) as? BackdropCollectionViewCell
                cell?.configure(with: item)
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.reuseIdentifier, for: indexPath) as? PosterCollectionViewCell
                cell?.configure(with: item)
                return cell
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.reuseIdentifier, for: indexPath) as? VideoCollectionViewCell
                cell?.configure(with: item)
                return cell
            default:
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCellId", for: indexPath)
            }
        })

        self.dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }

            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: GalleryHeaderReusableView.reuseIdentifier, for: indexPath) as? GalleryHeaderReusableView

            if indexPath.section == 0 {
                headerCell?.configure(with: NSLocalizedString("gallery_view_backdrops_header", comment: "Backdrops Header"))

            } else if indexPath.section == 1 {
                headerCell?.configure(with: NSLocalizedString("gallery_view_posters_header", comment: "Posters Header"))

            } else {
                headerCell?.configure(with: NSLocalizedString("gallery_view_videos_header", comment: "Videos Header"))
            }

            return headerCell
        }
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { [unowned self] (sectionIndex, _) -> NSCollectionLayoutSection? in

            if sectionIndex == 0 {
                return self.backdropSection()
            } else if sectionIndex == 1 {
                return self.posterSection()
            } else {
                return self.videoSection()
            }
        })
    }

    private func backdropSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1.0))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .uniform(size: 5.0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(UIScreen.main.bounds.height / (UIWindow.isLandscape ? 3 : 6)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        // Supplementary header view setup
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(UIScreen.main.bounds.height * 0.075))

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)

        sectionHeader.contentInsets = .init(horizontal: 0.0, vertical: 0.0)
        sectionHeader.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

    private func posterSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.333),
                                              heightDimension: .fractionalHeight(1.0))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .uniform(size: 5.0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(UIScreen.main.bounds.height / (UIWindow.isLandscape ? 2 : 3.5)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        // Supplementary header view setup
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(UIScreen.main.bounds.height * 0.075))

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)

        sectionHeader.contentInsets = .init(horizontal: 0.0, vertical: 0.0)
        sectionHeader.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

    private func videoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .uniform(size: 5.0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(UIScreen.main.bounds.height / (UIWindow.isLandscape ? 2 : 3.5)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        // Supplementary header view setup
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(UIScreen.main.bounds.height * 0.075))

        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)

        sectionHeader.contentInsets = .init(horizontal: 0.0, vertical: 0.0)
        sectionHeader.pinToVisibleBounds = true
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }

    private func setInitialData() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateDataSource(gallery: Gallery, animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()

            if gallery.backdrops?.isEmpty ?? true {
                snapshot.appendItems(["no_backdrops"], toSection: .backdrops)
            } else {
                snapshot.appendItems(gallery.backdrops?.map({ $0.filePath ?? ""}) ?? [], toSection: .backdrops)
            }

            if gallery.posters?.isEmpty ?? true {
                snapshot.appendItems(["no_posters"], toSection: .posters)
            } else {
                snapshot.appendItems(gallery.posters?.map({ $0.filePath ?? ""}) ?? [], toSection: .posters)
            }

            if gallery.videos?.isEmpty ?? true {
                snapshot.appendItems(["no_videos"], toSection: .videos)
            } else {
                snapshot.appendItems(gallery.videos?.map({ $0.key ?? ""}) ?? [], toSection: .videos)
            }

            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    // MARK: - ⚙️ Helpers
    @objc
    private func closeButtonPressed() {
        viewModel.inputs.closeButtonPressed()
    }

    private func openMovieVideo(videoURL: String) {
        if let url = URL(string: "https://www.youtube.com/watch?v=\(videoURL)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑", "GalleryVC deinit.")
    }
}

extension GalleryVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemUrl = dataSource.itemIdentifier(for: indexPath) else { return }

        switch indexPath.section {
        case 0:
            viewModel.inputs.backdropImageSelected(imageURL: itemUrl)
        case 1:
            viewModel.inputs.posterImageSelected(imageURL: itemUrl)
        case 2:
            openMovieVideo(videoURL: itemUrl)
        default:
            break
        }
    }
}
