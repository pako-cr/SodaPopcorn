//
//  NewMoviesListVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/9/21.
//

import Combine
import UIKit

final class NewMoviesListVC: BaseViewController {

	enum CollectionLayout: CGFloat {
		case list 		= 1.0
		case icons 		= 0.5
		case columns 	= 0.33333
	}

	enum Section: CaseIterable {
		case movies
	}

	// MARK: - Types
	typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
	typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>

	// MARK: - Consts
	private let viewModel: NewMoviesListVM

	// MARK: - Variables
	private var fetchMoviesSubscription: Cancellable!
	private var loadingSubscription: Cancellable!

	private var reloadingDataSource = false
	private lazy var dataSource = makeDataSource()

	private var collectionLayout: CollectionLayout = .list {
		didSet {
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else { return }
				// 􀭞 : square.fill.text.grid.1x2
				// 􀮞 : squareshape.split.2x2
				// 􀏟: rectangle.split.3x1

				var buttonImage: UIImage?
				switch self.collectionLayout {
					case .list:
						buttonImage = UIImage(systemName: "square.fill.text.grid.1x2")
					case .icons:
						buttonImage = UIImage(systemName: "squareshape.split.2x2")
					case .columns:
						buttonImage = UIImage(systemName: "rectangle.split.3x1")
				}

				self.navigationItem.rightBarButtonItem?.image = buttonImage
				self.movieCollectionView.setCollectionViewLayout(self.handleCollectionViewLayout(), animated: true)
			}
		}
	}

	private var loading = false {
		didSet {
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else { return }
				if !self.loading {
					self.refreshControl.endRefreshing()
				}
			}
		}
	}

	// MARK: - UI Elements
	private lazy var sizeMenu: UIMenu = { [unowned self] in
		let menu = UIMenu(title: NSLocalizedString("collection_view_set_size_menu_title", comment: "Select items size"), image: nil, identifier: nil, options: [.displayInline], children: [
			UIAction(title: "List", image: UIImage(systemName: "square.fill.text.grid.1x2"), handler: { (_) in
				self.collectionLayout = .list
			}),
			UIAction(title: "Icons", image: UIImage(systemName: "squareshape.split.2x2"), handler: { (_) in
				self.collectionLayout = .icons
			}),
			UIAction(title: "Columns", image: UIImage(systemName: "rectangle.split.3x1"), handler: { (_) in
				self.collectionLayout = .columns
			})
		])

		return menu
	}()

	private let refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(reloadCollectionView), for: .valueChanged)
		return refreshControl
	}()

	private let movieCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.register(MovieListCollectionViewCell.self, forCellWithReuseIdentifier: MovieListCollectionViewCell.reuseIdentifier)
		collectionView.register(SectionFooterReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SectionFooterReusableView.reuseIdentifier)
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.isScrollEnabled = true
		//		collectionView.showsVerticalScrollIndicator = false
		collectionView.allowsSelection = true
		collectionView.isPrefetchingEnabled = true
		return collectionView
	}()

	init(viewModel: NewMoviesListVM) {
		self.viewModel = viewModel
		super.init()
		self.reloadDataSource()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		configureCollectionViewLayout()
		bindViewModel()
		viewModel.inputs.fetchNewMovies()
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		view.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black

		let appearance = UINavigationBarAppearance()
		appearance.configureWithDefaultBackground()
		appearance.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
		navigationController?.navigationBar.standardAppearance = appearance
		navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance

		navigationItem.standardAppearance = appearance
	}

	override func setupUI() {
		navigationItem.title = NSLocalizedString("app_name_with_icon", comment: "App name")

		let barButtonImage = UIImage(systemName: "square.fill.text.grid.1x2")
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("collection_view_set_layout_button_title", comment: "Set collection layout"), image: barButtonImage, primaryAction: nil, menu: sizeMenu)

		view.addSubview(movieCollectionView)

		movieCollectionView.prefetchDataSource = self
		movieCollectionView.refreshControl = refreshControl
		movieCollectionView.delegate = self

		movieCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		movieCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
		movieCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
		movieCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
	}

	override func bindViewModel() {
		fetchMoviesSubscription = viewModel.outputs.fetchNewMoviesAction()
			.filter({ !($0?.isEmpty ?? true) })
			.sink(receiveValue: { [weak self] (movies) in
				guard let `self` = self, let movies = movies else { return }
				self.updateDataSource(movies: movies)
			})

		loadingSubscription = viewModel.outputs.loading()
			.sink(receiveValue: { [weak self] (loading) in
				guard let `self` = self else { return }
				self.loading = loading
			})
	}

	// MARK: - ⚙️ Helpers
	private func makeDataSource() -> DataSource {
		let cellRegistration = UICollectionView.CellRegistration<MovieListCollectionViewCell, Movie> { [weak self] cell, _, movie in
			guard let self = self else { return }
			cell.configure(with: movie, and: self.viewModel)
		}

		let dataSource = UICollectionViewDiffableDataSource<Section, Movie>(collectionView: movieCollectionView) { (collectionView, indexPath, movie) in
			return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: movie)
		}

		dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
			guard kind == UICollectionView.elementKindSectionFooter else { return nil }

			let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionFooterReusableView.reuseIdentifier, for: indexPath) as? SectionFooterReusableView
			return view
		}

		return dataSource
	}

	private func configureCollectionViewLayout() {
		movieCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), // CollectionLayout.list = 1.0 (initial size)
												  heightDimension: .fractionalHeight(1.0))

			let item = NSCollectionLayoutItem(layoutSize: itemSize)
			item.contentInsets = NSDirectionalEdgeInsets.uniform(size: 5)

			let groupSize = NSCollectionLayoutSize(
				widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
				heightDimension: NSCollectionLayoutDimension.absolute(UIScreen.main.bounds.height / 5)
			)

			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

			let section = NSCollectionLayoutSection(group: group)

			// Supplementary footer view setup
			let headerFooterSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .estimated(20)
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

			print("🔸 Snapshot items: \(snapshot.numberOfItems)")
			self.dataSource.apply(snapshot, animatingDifferences: true)
		}
	}

	private func reloadDataSource() {
		self.reloadingDataSource = false
		var snapshot = dataSource.snapshot()
		snapshot.deleteAllItems()
		snapshot.appendSections(Section.allCases)
		dataSource.apply(snapshot, animatingDifferences: true)
	}

	@objc
	private func reloadCollectionView() {
		reloadingDataSource = true
		viewModel.inputs.pullToRefresh()
	}

	@objc
	private func handleCollectionViewLayout() -> UICollectionViewLayout {
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(collectionLayout.rawValue),
											  heightDimension: .fractionalHeight(1.0))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)
		item.contentInsets = .uniform(size: 5)

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												  heightDimension: NSCollectionLayoutDimension.absolute(UIScreen.main.bounds.height / 5))

		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)

		let layout = UICollectionViewCompositionalLayout(section: section)

		return layout
	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑 NewMoviesListVC deinit.")
	}
}

extension NewMoviesListVC: UICollectionViewDataSourcePrefetching {
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		let numberOfItems = dataSource.snapshot().numberOfItems
		let lastItem = indexPaths.last?.item ?? 0

		if lastItem >= numberOfItems - 1 || lastItem >= numberOfItems {
			self.viewModel.inputs.fetchNewMovies()
		}
	}
}

extension NewMoviesListVC: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }
		viewModel.inputs.movieSelected(movie: movie)
	}
}
