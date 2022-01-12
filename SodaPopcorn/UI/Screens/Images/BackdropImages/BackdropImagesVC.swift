//
//  BackdropImagesVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

import Combine
import UIKit

final class BackdropImagesVC: BaseViewController {
    enum Section: CaseIterable {
        case images
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>

    // MARK: Consts
    private let viewModel: BackdropImagesVM

    // MARK: - Variables
    private var dataSource: DataSource!

    private var selectedImageSubscription: Cancellable?
    private var imagesSubscription: Cancellable?

    // MARK: UI Elements
    private var customCollectionView: UICollectionView!

    private lazy var closeButton: UIButton = {
        let image = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
        button.accessibilityLabel = NSLocalizedString("close", comment: "Close button")
        button.tintColor = UIColor(named: "PrimaryColor")
        return button
    }()

    init(viewModel: BackdropImagesVM) {
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
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        customCollectionView.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    override func setupUI() {
        view.addSubview(customCollectionView)
        view.addSubview(closeButton)

        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true

        customCollectionView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 0).isActive = true
        customCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        customCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override func bindViewModel() {
        imagesSubscription = viewModel.outputs.imagesAction()
            .sink(receiveValue: { [weak self] (images) in
                guard let `self` = self else { return }
                self.updateDataSource(images: images)
            })

        selectedImageSubscription = viewModel.outputs.selectedImageAction()
            .sink(receiveValue: { [weak self] selectedImage in
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    if let indexPath = self.dataSource.indexPath(for: selectedImage) {
                        self.customCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
                    }
                }
            })
    }

    // MARK: - Collection
    private func configureCollectionView() {
        customCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        customCollectionView.register(BackdropImageViewCell.self, forCellWithReuseIdentifier: BackdropImageViewCell.reuseIdentifier)
        customCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
        customCollectionView.translatesAutoresizingMaskIntoConstraints = false
        customCollectionView.isScrollEnabled = true
        customCollectionView.showsVerticalScrollIndicator = false
        customCollectionView.allowsSelection = true
        customCollectionView.isPrefetchingEnabled = true
        customCollectionView.alwaysBounceVertical = true
        customCollectionView.backgroundColor = UIColor.systemBackground
    }

    private func configureDataSource() {
        self.dataSource = DataSource(collectionView: customCollectionView, cellProvider: { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BackdropImageViewCell.reuseIdentifier, for: indexPath) as? BackdropImageViewCell
            cell?.configure(with: item, parentViewController: self)
            return cell
        })
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(1.0))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .uniform(size: 0.0)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            section.orthogonalScrollingBehavior = .groupPaging

            return section
        })
    }

    private func setInitialData() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateDataSource(images: [String], animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()
            snapshot.appendItems(images, toSection: .images)

            self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)

            self.viewModel.collectionViewUpdated()
        }
    }

    // MARK: - Helpers ⚙️
    @objc
    private func closeButtonPressed() {
        viewModel.inputs.closeButtonPressed()
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑 BackdropImagesVC deinit.")
    }
}
