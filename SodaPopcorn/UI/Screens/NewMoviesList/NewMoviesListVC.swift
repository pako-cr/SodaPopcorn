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

    private var loadedCount = 0

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
				self.movieCollectionView.setCollectionViewLayout(self.createLayout(), animated: true)
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
        refreshControl.tintColor = UIColor(named: "PrimaryColor")
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
		movieCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		movieCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		movieCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}

	override func bindViewModel() {
		fetchMoviesSubscription = viewModel.outputs.fetchNewMoviesAction()
			.filter({ !($0?.isEmpty ?? true) })
			.sink(receiveValue: { [weak self] (movies) in
				guard let `self` = self, let movies = movies, !movies.isEmpty else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                    self?.updateDataSource(movies: movies)
                }
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
		movieCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
		movieCollectionView.register(MovieListCollectionViewCell.self, forCellWithReuseIdentifier: MovieListCollectionViewCell.reuseIdentifier)
		movieCollectionView.register(SectionFooterReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SectionFooterReusableView.reuseIdentifier)
		movieCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "blankCellId")
		movieCollectionView.translatesAutoresizingMaskIntoConstraints = false
		movieCollectionView.isScrollEnabled = true
		movieCollectionView.showsVerticalScrollIndicator = false
		movieCollectionView.allowsSelection = true
		movieCollectionView.isPrefetchingEnabled = true
		movieCollectionView.refreshControl = refreshControl
		movieCollectionView.delegate = self
        movieCollectionView.alwaysBounceVertical = true
	}

	private func createLayout() -> UICollectionViewCompositionalLayout {
		return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] (_, _) -> NSCollectionLayoutSection? in
			guard let `self` = self else { return nil }

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(self.collectionLayout.rawValue),
                                                  heightDimension: .fractionalHeight(1.0))

			let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .uniform(size: 5.0)

			let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(UIScreen.main.bounds.height / (UIWindow.isLandscape ? 2 : 3.5)))

			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

			let section = NSCollectionLayoutSection(group: group)

			// Supplementary footer view setup
			let headerFooterSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .absolute(20))

			let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: headerFooterSize,
				elementKind: UICollectionView.elementKindSectionFooter,
				alignment: .bottom)

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

            self.loadedCount = snapshot.numberOfItems

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

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard loadedCount != 0 else { return }

        if indexPath.row == loadedCount - 1 {
            self.viewModel.inputs.fetchNewMovies()
        }
    }

	private func handleEmptyView() {
		let dataSourceItems = dataSource.snapshot().numberOfItems

		DispatchQueue.main.async { [weak self] in
			guard let `self` = self else { return }
			if self.loading && dataSourceItems < 1 {
				self.movieCollectionView.setEmptyView(title: NSLocalizedString("movie_list_view_controller_loading_movies_title_label", comment: "Loading title"),
                                                      message: NSLocalizedString("movie_list_view_controller_loading_movies_description_label", comment: "Loading Message"),
                                                      centered: true)

			} else if !self.loading && dataSourceItems < 1 {
				self.movieCollectionView.setEmptyView(title: NSLocalizedString("movie_list_view_controller_empty_movies_title_label", comment: "Empty list title"),
                                                      message: NSLocalizedString("movie_list_view_controller_empty_movies_description_label", comment: "Empty Message"),
                                                      centered: true)

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

extension NewMoviesListVC: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }
		viewModel.inputs.movieSelected(movie: movie)
	}
}
