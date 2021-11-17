//
//  SearchVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/11/21.
//

import Combine
import UIKit

final class SearchVC: BaseViewController {
    enum Section: CaseIterable {
        case genres
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Genre>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Genre>

    // MARK: - Consts
    private let viewModel: SearchVM

    // MARK: - Variables
    private var dataSource: DataSource!
    private var genresSubscription: Cancellable!
    private var moviesSubscription: Cancellable!
    private var loadingSubscription: Cancellable!
    private var showErrorSubscription: Cancellable!
    private var loading = false

    // MARK: UI Elements
    private var genresCollectionView: UICollectionView!

    // MARK: - UI Elements
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.isActive = true
        searchController.searchResultsUpdater = self
        return searchController
    }()

    init(viewModel: SearchVM) {
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

        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryColor")
        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
        genresCollectionView.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    override func setupUI() {
        view.addSubview(genresCollectionView)

        genresCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        genresCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        genresCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        genresCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("app_name_with_icon", comment: "App name")

        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryColor")
    }

    override func bindViewModel() {
//        moviesSubscription = viewModel.outputs.fetchMoviesAction()
//            .sink(receiveValue: { [weak self] movies in
//                self?.title = movie.title ?? NSLocalizedString("credits", comment: "Credits")
//            })

        showErrorSubscription = viewModel.outputs.showError()
            .sink(receiveValue: { [weak self] errorMessage in
                guard let `self` = self else { return }
                self.handleEmptyView()
                Alert.showAlert(on: self, title: NSLocalizedString("alert", comment: "Alert title"), message: errorMessage)
            })

        loadingSubscription = viewModel.outputs.loading()
            .sink(receiveValue: { [weak self] (loading) in
                guard let `self` = self else { return }
                self.loading = loading
            })

        genresSubscription = viewModel.outputs.genresAction()
            .sink(receiveValue: { [weak self] genres in
                self?.updateDataSource(genres: genres)
            })
    }

    // MARK: - Collection View
    private func configureCollectionView() {
        genresCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        genresCollectionView.register(GenreCollectionViewCell.self, forCellWithReuseIdentifier: GenreCollectionViewCell.reuseIdentifier)
        genresCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
        genresCollectionView.translatesAutoresizingMaskIntoConstraints = false
        genresCollectionView.isScrollEnabled = true
        genresCollectionView.showsVerticalScrollIndicator = false
        genresCollectionView.allowsSelection = true
        genresCollectionView.isPrefetchingEnabled = true
        genresCollectionView.delegate = self
        genresCollectionView.alwaysBounceVertical = true
        genresCollectionView.backgroundColor = UIColor.systemBackground
    }

    private func configureDataSource() {
        self.dataSource = DataSource(collectionView: genresCollectionView, cellProvider: { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCollectionViewCell.reuseIdentifier, for: indexPath) as? GenreCollectionViewCell
            cell?.configure(with: item)
            return cell
        })
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                  heightDimension: .fractionalHeight(1.0))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .uniform(size: 2.0)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(UIScreen.main.bounds.height / (UIWindow.isLandscape ? 3 : 6)))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)

            return section
        })
    }

    private func setInitialData() {
        var snapshot = self.dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateDataSource(genres: [Genre]?, animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()

            if let genres = genres, !genres.isEmpty {
                snapshot.appendItems(genres, toSection: .genres)
            }

            self.dataSource.apply(snapshot, animatingDifferences: true)
            self.handleEmptyView()
        }
    }

    func handleEmptyView() {
        let dataSourceItems = dataSource.snapshot().numberOfItems

        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.loading && dataSourceItems < 1 {
                self.genresCollectionView.setEmptyView(title: NSLocalizedString("loading_genres_title_label", comment: "Loading title"),
                                                 message: NSLocalizedString("loading_genres_description_label", comment: "Loading Message"),
                                                 centeredY: true)

            } else if !self.loading && dataSourceItems < 1 {
                self.genresCollectionView.setEmptyView(title: NSLocalizedString("empty_genres_title_label", comment: "Empty list title"),
                                                 message: NSLocalizedString("empty_genres_description_label", comment: "Empty list message"),
                                                 centeredY: true)

            } else {
                self.genresCollectionView.removeEmptyView()
            }
        }
    }

    // MARK: - ⚙️ Helpers

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑 SearchVC deinit.")
    }
}

extension SearchVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let genre = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.inputs.genreSelected(genre: genre)
    }
}

extension SearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.showsSearchResultsController = true
        if let searchQuery = searchController.searchBar.text {
            viewModel.inputs.searchTextDidChange(searchQuery: searchQuery)
        }
    }
}
