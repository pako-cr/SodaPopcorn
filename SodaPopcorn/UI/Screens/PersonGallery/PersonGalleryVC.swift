//
//  PersonGalleryVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 12/11/21.
//

import Combine
import UIKit

final class PersonGalleryVC: BaseViewController {
    enum Section: CaseIterable {
        case images
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, String>

    // MARK: Consts
    private let viewModel: PersonGalleryVM

    // MARK: - Variables
    private var dataSource: DataSource!
    private var imagesSubscription: Cancellable!
    private var personSubscription: Cancellable!

    // MARK: UI Elements
    private var customCollectionView: UICollectionView!

    init(viewModel: PersonGalleryVM) {
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

    override func bindViewModel() {
        imagesSubscription = viewModel.outputs.imagesAction()
            .sink(receiveValue: { [weak self] images in
                guard let `self` = self else { return }
                self.updateDataSource(images: images)
            })

        personSubscription = viewModel.outputs.personAction()
            .sink(receiveValue: { [weak self] person in
                self?.title = String(format: NSLocalizedString("person_gallery", comment: "Person Gallery"), person.name ?? "")
            })
    }

    private func setupNavigationBar() {
        let leftBarButtonItemImage = UIImage(systemName: "arrow.backward")?.withRenderingMode(.alwaysTemplate)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarButtonItemImage, style: .done, target: self, action: #selector(closeButtonPressed))

        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryColor")
    }

    // MARK: - Collection
    private func configureCollectionView() {
        customCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        customCollectionView.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier)
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
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCell.reuseIdentifier, for: indexPath) as? ProfileCollectionViewCell
            cell?.configure(with: item)
            return cell
        })
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.333),
                                                  heightDimension: .fractionalHeight(1.0))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .uniform(size: 2.0)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(UIScreen.main.bounds.height / (UIWindow.isLandscape ? 1.75 : 3.75)))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            return section
        })
    }

    private func setInitialData() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateDataSource(images: [PersonImage]?, animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()

            if images?.isEmpty ?? true {
                snapshot.appendItems(["no_profiles"], toSection: .images)
            } else {
                snapshot.appendItems(images?.map({ $0.filePath ?? ""}) ?? [], toSection: .images)
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
        print("🗑", "PersonGalleryVC deinit.")
    }
}

extension PersonGalleryVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemUrl = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.inputs.imageSelected(imageUrl: itemUrl)
    }
}
