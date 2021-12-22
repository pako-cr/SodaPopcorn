//
//  CreditsVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 10/11/21.
//

import Domain
import Combine
import UIKit

final class CreditsVC: BaseViewController {
    enum Section: CaseIterable {
        case cast
        case crew
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Cast>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cast>

    // MARK: Consts
    private let viewModel: CreditsVM

    // MARK: - Variables
    private var dataSource: DataSource!
    private var creditsSubscription: Cancellable!
    private var movieSubscription: Cancellable!
    private var loadingSubscription: Cancellable!
    private var showErrorSubscription: Cancellable!

    // MARK: UI Elements
    private var customCollectionView: UICollectionView!

    init(viewModel: CreditsVM) {
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
        customCollectionView.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func setupUI() {
        view.addSubview(customCollectionView)

        customCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        customCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        customCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override func bindViewModel() {
        creditsSubscription = viewModel.outputs.creditsAction()
            .sink(receiveValue: { [weak self] credits in
                guard let `self` = self else { return }
                self.updateDataSource(credits: credits)
            })

        movieSubscription = viewModel.outputs.movieAction()
            .sink(receiveValue: { [weak self] movie in
                self?.title = movie.title ?? NSLocalizedString("credits", comment: "Credits")
            })
    }

    // MARK: - Collection View
    private func configureCollectionView() {
        customCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        customCollectionView.register(CastCollectionViewCell.self, forCellWithReuseIdentifier: CastCollectionViewCell.reuseIdentifier)
        customCollectionView.register(CreditsHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                      withReuseIdentifier: CreditsHeaderReusableView.reuseIdentifier)
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
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCollectionViewCell.reuseIdentifier, for: indexPath) as? CastCollectionViewCell
                cell?.configure(with: item)
                return cell
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCollectionViewCell.reuseIdentifier, for: indexPath) as? CastCollectionViewCell
                cell?.configure(with: item)
                return cell
            default:
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCellId", for: indexPath)
            }
        })

        self.dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }

            let headerCell = collectionView
                .dequeueReusableSupplementaryView(ofKind: kind,
                                                  withReuseIdentifier: CreditsHeaderReusableView.reuseIdentifier, for: indexPath) as? CreditsHeaderReusableView
            if indexPath.section == 0 {
                headerCell?.configure(with: NSLocalizedString("credits_vc_cast_header", comment: "Cast Header"))

            } else {
                headerCell?.configure(with: NSLocalizedString("credits_vc_crew_header", comment: "Crew Header"))
            }

            return headerCell
        }
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.333),
                                                  heightDimension: .fractionalHeight(1.0))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .uniform(size: 2.0)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(UIScreen.main.bounds.height / (UIDevice.isLandscape ? 1 : 3.5)))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            // Supplementary header view setup
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(UIScreen.main.bounds.height * (UIDevice.isLandscape ? 0.1 : 0.05)))

            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)

            sectionHeader.contentInsets = .init(horizontal: 0.0, vertical: 0.0)
            sectionHeader.pinToVisibleBounds = true
            section.boundarySupplementaryItems = [sectionHeader]

            return section
        })
    }

    private func setInitialData() {
        var snapshot = self.dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateDataSource(credits: Credits, animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()

            if let cast = credits.cast, !cast.isEmpty {
                snapshot.appendItems(cast, toSection: .cast)
            } else {
                snapshot.appendItems([Cast()], toSection: .cast)
            }

            if let crew = credits.crew, !crew.isEmpty {
                snapshot.appendItems(crew, toSection: .crew)
            } else {
                snapshot.appendItems([Cast()], toSection: .crew)
            }

            self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }

    // MARK: - ⚙️ Helpers
    @objc
    private func closeButtonPressed() {
        viewModel.inputs.closeButtonPressed()
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑", "CreditsVC deinit.")
    }
}

extension CreditsVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cast = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.inputs.castMemberSelected(cast: cast)
    }
}
