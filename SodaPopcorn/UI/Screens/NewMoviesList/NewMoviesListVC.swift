//
//  NewMoviesListVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/9/21.
//

import Combine
import UIKit

final class NewMoviesListVC: BaseViewController {
	enum Section: CaseIterable {
		case movies
	}

	// MARK: - Types
	typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
	typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>

	// MARK: - Consts
	private let viewModel: NewMoviesListVM

	// MARK: - Variables

	// MARK: Subscriptions
	private var finishedFetchingSubscription: Cancellable!
	private var fetchMoviesSubscription: Cancellable!
	private var loadingSubscription: Cancellable!
	private var showErrorSubscription: Cancellable!

	private var finishedFetching = false
	private var reloadingDataSource = false
	private var dataSource: DataSource!

	private var collectionLayout: CollectionLayout = .columns {
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

				self.navigationItem.rightBarButtonItem?.image = buttonImage
				self.movieCollectionView.setCollectionViewLayout(self.handleCollectionViewLayoutChange(), animated: true)
			}
		}
	}

	private var loading = false {
		didSet {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
				guard let `self` = self else { return }
				if !self.loading {
					self.refreshControl.endRefreshing()
				}
			}
		}
	}

	// MARK: - UI Elements
	private var movieCollectionView: UICollectionView!

	private lazy var sizeMenu: UIMenu = { [unowned self] in
		let menu = UIMenu(title: NSLocalizedString("collection_view_set_size_menu_title", comment: "Select items size"), image: nil, identifier: nil, options: [.displayInline], children: [
			UIAction(title: "Columns", image: UIImage(systemName: "rectangle.split.3x1"), handler: { (_) in
				self.collectionLayout = .columns
			}),
			UIAction(title: "List", image: UIImage(systemName: "square.fill.text.grid.1x2"), handler: { (_) in
				self.collectionLayout = .list
			})
		])

		return menu
	}()

	private lazy var refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadCollectionView), for: .valueChanged)
		return refreshControl
	}()

	init(viewModel: NewMoviesListVM) {
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
		setupUI()
		bindViewModel()
		viewModel.inputs.fetchNewMovies()
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryColor")
		view.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
	}

	override func setupUI() {
		navigationItem.title = NSLocalizedString("app_name_with_icon", comment: "App name")

		let barButtonImage = UIImage(systemName: "square.fill.text.grid.1x2")
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("collection_view_set_layout_button_title", comment: "Set collection layout"), image: barButtonImage, primaryAction: UIAction { _ in self.setCollectionViewLayout() }, menu: sizeMenu)

		view.addSubview(movieCollectionView)

		movieCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		movieCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
		movieCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
		movieCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
	}

	override func bindViewModel() {
		fetchMoviesSubscription = viewModel.outputs.fetchNewMoviesAction()
			.filter({ !($0?.isEmpty ?? true) })
			.sink(receiveValue: { [weak self] (movies) in
				guard let `self` = self, let movies = movies, !movies.isEmpty else { return }
				self.updateDataSource(movies: movies)
			})

		loadingSubscription = viewModel.outputs.loading()
			.sink(receiveValue: { [weak self] (loading) in
				guard let `self` = self else { return }
				self.loading = loading
			})

		finishedFetchingSubscription = viewModel.outputs.finishedFetchingAction()
			.sink(receiveValue: { [weak self] (finishedFetching) in
				guard let `self` = self else { return }

				if self.finishedFetching != finishedFetching {
					self.handleFetchingChange(finishedFetching: finishedFetching)
				}
			})

		showErrorSubscription = viewModel.outputs.showError()
			.sink(receiveValue: { [weak self] errorMessage in
				guard let `self` = self else { return }
				self.handleEmptyView()
				Alert.showAlert(on: self, title: NSLocalizedString("alert", comment: "Alert title"), message: errorMessage)
			})
	}

	// MARK: - ⚙️ Helpers
	private func configureCollectionView() {
		movieCollectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
		movieCollectionView.register(MovieListCollectionViewCell.self, forCellWithReuseIdentifier: MovieListCollectionViewCell.reuseIdentifier)
		movieCollectionView.register(SectionFooterReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SectionFooterReusableView.reuseIdentifier)
		movieCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
		movieCollectionView.translatesAutoresizingMaskIntoConstraints = false
		movieCollectionView.isScrollEnabled = true
		movieCollectionView.showsVerticalScrollIndicator = false
		movieCollectionView.allowsSelection = true
		movieCollectionView.isPrefetchingEnabled = true
		movieCollectionView.prefetchDataSource = self
		movieCollectionView.refreshControl = refreshControl
		movieCollectionView.delegate = self
	}

	private func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
		return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (_, _) -> NSCollectionLayoutSection? in
			guard let `self` = self else { return nil }
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(self.collectionLayout.rawValue),
												  heightDimension: .fractionalHeight(1.0))

			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = NSDirectionalEdgeInsets.uniform(size: 5)

			let groupSize = NSCollectionLayoutSize(
				widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
				heightDimension: NSCollectionLayoutDimension.absolute(UIScreen.main.bounds.height / 4)
			)

			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

			let section = NSCollectionLayoutSection(group: group)

			// Supplementary footer view setup
			let headerFooterSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .absolute(50)
			)
			let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerFooterSize,
				elementKind: UICollectionView.elementKindSectionFooter,
				alignment: .bottom
			)

			section.boundarySupplementaryItems = [sectionFooter]

			return section
		})
	}

	private func configureDataSource() {
		let cellRegistration = UICollectionView.CellRegistration<MovieListCollectionViewCell, Movie> { cell, _, movie in
			cell.configure(with: movie)
		}

		let dataSource = UICollectionViewDiffableDataSource<Section, Movie>(collectionView: movieCollectionView) { (collectionView, indexPath, movie) in
			return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
		}

		dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
			guard kind == UICollectionView.elementKindSectionFooter else { return nil }

			return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionFooterReusableView.reuseIdentifier, for: indexPath) as? SectionFooterReusableView
		}

		self.dataSource = dataSource
	}

	private func setInitialData() {
		var snapshot = dataSource.snapshot()
		snapshot.appendSections(Section.allCases)
		self.dataSource.apply(snapshot, animatingDifferences: false)
		self.handleEmptyView()
	}

	private func updateDataSource(movies: [Movie], animatingDifferences: Bool = true) {
		DispatchQueue.main.async { [weak self] in
			guard let `self` = self else { return }

			if self.reloadingDataSource {
				self.reloadDataSource()
			}

			var snapshot = self.dataSource.snapshot()
			if let lastItem = snapshot.itemIdentifiers.last {
				snapshot.insertItems(movies, afterItem: lastItem)
			} else {
				snapshot.appendItems(movies, toSection: .movies)
			}

			self.handleFetchingChange(finishedFetching: false)

			print("🔸 Snapshot items: \(snapshot.numberOfItems)")
			self.movieCollectionView.removeEmptyView()
			self.dataSource.apply(snapshot, animatingDifferences: true)
		}
	}

	private func reloadDataSource() {
		self.reloadingDataSource = false
		var snapshot = dataSource.snapshot()
		snapshot.deleteAllItems()
		snapshot.appendSections(Section.allCases)

		self.dataSource.apply(snapshot, animatingDifferences: true)
        cache.removeAllValues()
	}

	@objc
	private func reloadCollectionView() {
		reloadingDataSource = true
		viewModel.inputs.pullToRefresh()
	}

	@objc
	private func handleCollectionViewLayoutChange() -> UICollectionViewLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(collectionLayout.rawValue),
											  heightDimension: .fractionalHeight(1.0))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = .uniform(size: 5)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												  heightDimension: NSCollectionLayoutDimension.absolute(UIScreen.main.bounds.height / 4))

		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)

		let headerFooterSize = NSCollectionLayoutSize(
			widthDimension: .fractionalWidth(1.0),
			heightDimension: .absolute(20)
		)

		let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
			layoutSize: headerFooterSize,
			elementKind: UICollectionView.elementKindSectionFooter,
			alignment: .bottom
		)
		section.boundarySupplementaryItems = [sectionFooter]

		return UICollectionViewCompositionalLayout(section: section)
	}

	private func setCollectionViewLayout() {
		switch collectionLayout {
			case .columns:
				self.collectionLayout = .list
			case .list:
				self.collectionLayout = .columns
		}
	}

	/// Handle when all the information is fetched or is going to start fetching all over again to set on or off the loading animation.
	/// Called in the subscription *finishedFetchingAction*
	private func handleFetchingChange(finishedFetching: Bool) {
		dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
			guard kind == UICollectionView.elementKindSectionFooter else { return nil }

			let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionFooterReusableView.reuseIdentifier, for: indexPath) as? SectionFooterReusableView
			_ = finishedFetching ? footerView?.stopActivityIndicator() : footerView?.startActivityIndicator()
			return footerView
		}

		self.finishedFetching = finishedFetching
	}

	private func handleEmptyView() {
		let dataSourceItems = dataSource.snapshot().numberOfItems

		DispatchQueue.main.async { [weak self] in
			guard let `self` = self else { return }
			if self.loading && dataSourceItems < 1 {
				self.movieCollectionView.setEmptyView(title: "Loading", message: "Loading Message", centered: true)

			} else if !self.loading && dataSourceItems < 1 {
				self.movieCollectionView.setEmptyView(title: "Empty", message: "Empty Message", centered: true)

			} else {
				self.movieCollectionView.removeEmptyView()
			}
		}
	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑 NewMoviesListVC deinit.")
		fetchMoviesSubscription.cancel()
		loadingSubscription.cancel()
		finishedFetchingSubscription.cancel()
	}
}

extension NewMoviesListVC: UICollectionViewDataSourcePrefetching {
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		let numberOfItems = dataSource.snapshot().numberOfItems
		let lastItem = indexPaths.last?.item ?? 0

		if (numberOfItems - 1)...numberOfItems ~= lastItem {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
				self?.viewModel.inputs.fetchNewMovies()
			}
		}
	}
}

extension NewMoviesListVC: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }
		viewModel.inputs.movieSelected(movie: movie)
	}
}
