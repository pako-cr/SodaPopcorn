//
//  NewMoviesListViewController.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/9/21.
//

import Combine
import UIKit

final class NewMoviesListViewController: BaseViewController {

	enum Section: CaseIterable {
		case movies
	}

	// MARK: - Consts
	private let posterImageViewModel = PosterImageViewModel()
	private let viewModel: NewMoviesListViewModel

	// MARK: - Types
	typealias DataSource = UICollectionViewDiffableDataSource<Section, Movie>
	typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Movie>

	// MARK: - Variables
	private var fetchMoviesSubscription: Cancellable!
	private var loadingSubscription: Cancellable!

	private var reloadingDataSource = false
	private var snapshot = Snapshot()
	private lazy var dataSource = makeDataSource()

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
	private let refreshControl: UIRefreshControl = {
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(reloadCollectionView), for: .valueChanged)
		return refreshControl
	}()

	private var movieCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.register(MovieListCollectionViewCell.self, forCellWithReuseIdentifier: MovieListCollectionViewCell.reuseIdentifier)
		collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.isScrollEnabled = true
//		collectionView.showsVerticalScrollIndicator = false
		collectionView.allowsSelection = true
		collectionView.isPrefetchingEnabled = true
		return collectionView
	}()

	init(viewModel: NewMoviesListViewModel) {
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
		movieCollectionView.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
		navigationController?.navigationBar.isTranslucent = traitCollection.userInterfaceStyle == .light ? false : true

		let appearance = UINavigationBarAppearance()
		appearance.configureWithDefaultBackground()
		appearance.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
		navigationController?.navigationBar.standardAppearance = appearance
		navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance

		navigationItem.standardAppearance = appearance
	}

	override func setupUI() {
		navigationController?.title = NSLocalizedString("app_name_with_icon", comment: "App name")
		navigationItem.title = NSLocalizedString("app_name_with_icon", comment: "App name")

		view.addSubview(movieCollectionView)

		movieCollectionView.prefetchDataSource = self
		movieCollectionView.refreshControl = refreshControl

		movieCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		movieCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
		movieCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
		movieCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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

//		subscription = posterImageViewModel.outputs.fetchPosterImageSignal()
//			.sink(receiveValue: { [weak self] (movieInfo) in
//				guard let `self` = self else { return }
//				self.setPosterImageData(movieId: movieInfo.0, imageData: movieInfo.1)
//			})
	}

	// MARK: - ⚙️ Helpers
//	private func setPosterImageData(movieId: String, imageData: Data) {
//		if let index = self.dataSource.firstIndex(where: { $0.id == movieId }) {
//			DispatchQueue.main.async { [weak self] in
//				guard let `self` = self else { return }
//				self.dataSource[index].posterImageData = imageData
//			}
//		}
//
//		self.dataSource.itemIdentifier(for: indexPath)
//	}

	private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Movie> {
		return UICollectionViewDiffableDataSource(
			collectionView: movieCollectionView,
			cellProvider: { collectionView, indexPath, movie in
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieListCollectionViewCell
				cell?.configure(with: movie, and: self.posterImageViewModel)
				return cell
			}
		)
	}

	private func updateDataSource(movies: [Movie], animatingDifferences: Bool = true) {
		DispatchQueue.main.async { [weak self] in
			guard let `self` = self else { return }

			if self.reloadingDataSource {
				self.reloadDataSource()
			}

			self.snapshot.appendItems(movies, toSection: .movies)
			print("🔸 Snapshot items: \(self.snapshot.numberOfItems)")
			self.dataSource.apply(self.snapshot, animatingDifferences: true)
		}
	}

	private func reloadDataSource() {
		self.reloadingDataSource = false
		self.snapshot.deleteAllItems()
		self.snapshot.appendSections(Section.allCases)
		self.dataSource.apply(self.snapshot, animatingDifferences: true)
	}

	private func configureCollectionViewLayout() {
		movieCollectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: { (_, layoutEnvironment) -> NSCollectionLayoutSection? in
			let isPhone = layoutEnvironment.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.phone
			let size = NSCollectionLayoutSize(
				widthDimension: NSCollectionLayoutDimension.fractionalWidth(1),
				heightDimension: NSCollectionLayoutDimension.absolute(UIScreen.main.bounds.height / 5)
			)

			let itemCount = isPhone ? 1 : 3
			let item = NSCollectionLayoutItem(layoutSize: size)
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: itemCount)
			let section = NSCollectionLayoutSection(group: group)
			section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
			section.interGroupSpacing = 10

			return section
		})
	}

	@objc
	private func reloadCollectionView() {
		reloadingDataSource = true
		viewModel.inputs.pullToRefresh()
	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑 NewMoviesListViewController deinit.")
	}
}

extension NewMoviesListViewController: UICollectionViewDataSourcePrefetching {
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		if (indexPaths.last?.item ?? 0) >= (dataSource.snapshot().numberOfItems - 1) {
			self.viewModel.inputs.fetchNewMovies()
		}
	}
}
