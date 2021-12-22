//
//  SearchVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/11/21.
//

import Combine
import Domain
import UIKit

final class SearchVC: BaseViewController {
    enum Section: CaseIterable {
        case genres
        case movies
    }

    // MARK: - Types
    typealias DataSource = UICollectionViewDiffableDataSource<Section, SearchObject>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SearchObject>

    // MARK: - Consts
    private let viewModel: SearchVM

    private var genres: [Genre]?
    private var currentSearchControllerStatus = false

    // MARK: - Variables
    private var finishedFetchingSubscription: Cancellable!
    private var finishedFetching = false

    private var dataSource: DataSource!
    private var genresSubscription: Cancellable!
    private var moviesSubscription: Cancellable!
    private var loadingSubscription: Cancellable!
    private var showErrorSubscription: Cancellable!
    private var searchControllerDidChangeSubscription: Cancellable!
    private var loading = false

    // MARK: UI Elements
    private var collectionView: UICollectionView!

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
        collectionView.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    override func setupUI() {
        view.addSubview(collectionView)

        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigationItem.title = NSLocalizedString("app_name_with_icon", comment: "App name")

        navigationItem.searchController = searchController
    }

    override func bindViewModel() {
        moviesSubscription = viewModel.outputs.fetchMoviesAction()
            .sink(receiveValue: { [weak self] movies in
                guard let `self` = self else { return }

                if !(movies?.isEmpty ?? true) {
                    if self.currentSearchControllerStatus {
                        self.updateDataSource(movies: movies, animatingDifferences: true)
                    }
                }
            })

        showErrorSubscription = viewModel.outputs.showError()
            .sink(receiveValue: { [weak self] errorMessage in
                guard let `self` = self else { return }
                self.handleEmptyView()
                Alert.showAlert(on: self, title: NSLocalizedString("alert", comment: "Alert title"), message: errorMessage)
            })

        loadingSubscription = viewModel.outputs.loading()
            .sink(receiveValue: { [weak self] (loading) in
                DispatchQueue.main.async { [weak self] in
                    self?.loading = loading
                    self?.searchController.searchBar.isLoading = loading
                }
            })

        genresSubscription = viewModel.outputs.genresAction()
            .sink(receiveValue: { [weak self] genres in
                self?.genres = genres
                self?.updateDataSource(genres: genres)
            })

        searchControllerDidChangeSubscription = viewModel.outputs.searchControllerDidChangeAction()
            .sink(receiveValue: { [weak self] isActive in
                guard let `self` = self else { return }

                if isActive {
                    self.updateDataSource(genres: [], animatingDifferences: true)

                } else {
                    self.updateDataSource(genres: self.genres, animatingDifferences: true)
                }
            })
    }

    // MARK: - Collection View
    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(GenreCollectionViewCell.self, forCellWithReuseIdentifier: GenreCollectionViewCell.reuseIdentifier)
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.reuseIdentifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.allowsSelection = true
        collectionView.isPrefetchingEnabled = true
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.systemBackground
    }

    private func configureDataSource() {
        self.dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            switch indexPath.section {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GenreCollectionViewCell.reuseIdentifier, for: indexPath) as? GenreCollectionViewCell
                if let genre = item.genre {
                    cell?.configure(with: genre)
                    return cell
                }
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCellId", for: indexPath)

            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieCollectionViewCell
                if let movie = item.movie {
                    cell?.configure(with: movie)
                    return cell
                }
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCellId", for: indexPath)
            default:
                return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCellId", for: indexPath)
            }
        })
    }

    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout(sectionProvider: { [unowned self] (sectionIndex, _) -> NSCollectionLayoutSection? in

            switch sectionIndex {
            case 0:
                return self.genresSection()
            default:
                return self.moviesSection()
            }
        })
    }

    private func genresSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .uniform(size: 2.0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(UIScreen.main.bounds.height / (UIDevice.isLandscape ? 2.5 : 4.5)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        return section
    }

    private func moviesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets.uniform(size: 2.0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(UIScreen.main.bounds.height / (UIDevice.isLandscape ? 1.5 : 3.75)))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        return section
    }

    private func setInitialData() {
        var snapshot = self.dataSource.snapshot()
        snapshot.appendSections(Section.allCases)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateDataSource(genres: [Genre]? = nil, movies: [Movie]? = nil, animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()

            if let genres = genres, !genres.isEmpty {
                snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .movies))
                snapshot.appendItems(genres.map({ SearchObject(genre: Genre(id: $0.id, name: $0.name) )}), toSection: .genres)
            } else {
                snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .genres))
            }

            if let movies = movies, !movies.isEmpty {
                snapshot.deleteItems(snapshot.itemIdentifiers(inSection: .movies))
                snapshot.appendItems(movies.map({ SearchObject(movie: Movie(movieId: $0.movieId, title: $0.title, overview: $0.overview, rating: $0.rating, posterPath: $0.posterPath, backdropPath: $0.backdropPath, releaseDate: $0.releaseDate)) }), toSection: .movies)
            }

            self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
            self.handleEmptyView()
        }
    }

    func handleEmptyView() {
        let dataSourceItems = dataSource.snapshot().numberOfItems

        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.loading && dataSourceItems < 1 {
                self.collectionView.setEmptyView(title: NSLocalizedString("loading_genres_title_label", comment: "Loading title"),
                                                 message: NSLocalizedString("loading_genres_description_label", comment: "Loading Message"),
                                                 centeredY: true)

            } else if !self.loading && dataSourceItems < 1 {
                self.collectionView.setEmptyView(title: NSLocalizedString("search_content_title", comment: "Search title"),
                                                 message: NSLocalizedString("search_content_description", comment: "Search description"),
                                                 centeredY: true)

            } else {
                self.collectionView.removeEmptyView()
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

        switch indexPath.section {
        case 0:
            guard let genre = dataSource.itemIdentifier(for: indexPath)?.genre else { return }
            viewModel.inputs.genreSelected(genre: genre)
        case 1:
            guard let movie = dataSource.itemIdentifier(for: indexPath)?.movie else { return }
            viewModel.inputs.movieSelected(movie: movie)
        default:
            break
        }
    }
}

extension SearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.showsSearchResultsController = true

        if currentSearchControllerStatus != searchController.isActive {
            self.currentSearchControllerStatus = searchController.isActive
            viewModel.inputs.searchControllerDidChange(isActive: searchController.isActive)
        }

        if let searchQuery = searchController.searchBar.text {
            viewModel.inputs.searchTextDidChange(searchQuery: searchQuery)

            if !searchQuery.isEmpty, searchQuery.count >= 4 {
                DispatchQueue.main.async { [weak self] in
                    self?.searchController.searchBar.isLoading = true
                }
            }
        }
    }
}

extension SearchVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cells = collectionView.visibleCells as? [GenreCollectionViewCell] {
            let bounds = collectionView.bounds

            cells.forEach { cell in
                cell.updateParallaxOffset(collectionViewBounds: bounds)
            }
        }
    }
}
