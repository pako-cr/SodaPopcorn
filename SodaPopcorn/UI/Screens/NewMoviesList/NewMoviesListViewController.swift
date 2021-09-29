//
//  NewMoviesListViewController.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/9/21.
//

import Combine
import UIKit

final class NewMoviesListViewController: BaseViewController {
	// MARK: - Consts
	private var viewModel: NewMoviesListViewModel?
	private let posterImageViewModel = PosterImageViewModel()

	// MARK: - Variables
	private var cancellable = Set<AnyCancellable>()
	private var loading = false {
		didSet {
			DispatchQueue.main.async { [weak self] in
				self?.refreshControl.endRefreshing()
			}
		}
	}

//	private let loadingQueue = OperationQueue()
//	private var loadingOperations = [IndexPath: DataLoadOperation]	
	private var dataSource: [Movie] = [] {
		didSet {
			DispatchQueue.main.async { [weak self] in
				print("🔸 Reloading data source!")
				self?.movieCollectionView.reloadData()
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
		collectionView.allowsSelection = true
		collectionView.isPrefetchingEnabled = true
		return collectionView
	}()

	convenience init(viewModel: NewMoviesListViewModel) {
		self.init(nibName: nil, bundle: nil)
		self.viewModel = viewModel
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		viewModel?.inputs.viewDidLoad()
    }

	override func viewWillLayoutSubviews() {
		movieCollectionView.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
		navigationController?.navigationBar.isTranslucent = traitCollection.userInterfaceStyle == .light ? false : true

		let appearance = UINavigationBarAppearance()
		appearance.configureWithDefaultBackground()
		appearance.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
		navigationController?.navigationBar.standardAppearance = appearance
		navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance

//		let appearance = navigationController?.navigationBar.standardAppearance.copy()
			// Configure appearance
		navigationItem.standardAppearance = appearance
	}

	override func setupUI() {
		navigationController?.title = NSLocalizedString("app_name_with_icon", comment: "App name")
		navigationItem.title = NSLocalizedString("app_name_with_icon", comment: "App name")

		view.addSubview(movieCollectionView)

		movieCollectionView.dataSource = self
		movieCollectionView.prefetchDataSource = self
		movieCollectionView.delegate = self
		movieCollectionView.refreshControl = refreshControl

		movieCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
		movieCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
		movieCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
		movieCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
	}

	override func bindViewModel() {
		viewModel?.outputs.fetchNewMoviesAction()
			.sink(receiveValue: { [weak self] (movies) in
				guard let `self` = self, let movies = movies else { return }
				self.dataSource.insert(contentsOf: movies, at: self.dataSource.count)
			}).store(in: &cancellable)

		viewModel?.outputs.loading()
			.sink(receiveValue: { [weak self] (loading) in
				guard let `self` = self else { return }
				self.loading = loading
			}).store(in: &cancellable)

		posterImageViewModel.outputs.fetchPosterImageSignal()
			.sink(receiveValue: { [weak self] (movieInfo) in
				guard let `self` = self else { return }
				self.setPosterImageData(movieId: movieInfo.0, imageData: movieInfo.1)
			}).store(in: &cancellable)
	}

	// MARK: - ⚙️ Helpers
	private func setPosterImageData(movieId: Int, imageData: Data) {
		if let index = self.dataSource.firstIndex(where: { $0.id == movieId }) {
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else { return }
				self.dataSource[index].posterImageData = imageData
			}
		}
	}

	@objc
	private func reloadCollectionView() {
		viewModel?.inputs.pullToRefresh()
	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑 NewMoviesListViewController deinit.")
	}
}

extension NewMoviesListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if self.dataSource.count < 1 {
			let title = loading ?
				NSLocalizedString("movie_list_view_controller_loading_movies_title_label", comment: "Loading title") :
			NSLocalizedString("movie_list_view_controller_no_movies_to_show_title_label", comment: "No results title")

			let description = loading  ?
				NSLocalizedString("movie_list_view_controller_loading_movies_description_label", comment: "Loading description") :
				NSLocalizedString("movie_list_view_controller_no_movies_to_show_description_label", comment: "No results description")

			collectionView.setEmptyView(title: title, message: description)
		} else {
			collectionView.restore()
		}

		return self.dataSource.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCollectionViewCell.reuseIdentifier, for: indexPath) as? MovieListCollectionViewCell {
			cell.configure(with: dataSource[indexPath.item], and: posterImageViewModel)
			return cell
		}

		return collectionView.dequeueReusableCell(withReuseIdentifier: "blankCellId", for: indexPath)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height / 5)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
	}
}

extension NewMoviesListViewController: UICollectionViewDataSourcePrefetching {
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {

		print("🔸 Prefetching: \(indexPaths)")
//		for indexPath in indexPaths {
		if indexPaths.last?.row == self.dataSource.count - 5 {
			self.viewModel?.inputs.fetchNewMovies()
		}
//			let model = models[indexPath.row]
//			asyncFetcher.fetchAsync(model.identifier)
//		}
	}
}
