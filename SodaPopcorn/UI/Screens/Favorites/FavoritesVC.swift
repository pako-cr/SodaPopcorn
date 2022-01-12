//
//  FavoritesVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 26/11/21.
//

import Combine
import Domain
import UIKit

final class FavoritesVC: MoviesBaseCollectionView {
    // MARK: - Consts
    private let viewModel: FavoritesVM

    // MARK: Subscriptions
    private var finishedFetchingSubscription: Cancellable?
    private var fetchMoviesSubscription: Cancellable?
    private var movieIncludedSubscription: Cancellable?
    private var movieRemovedSubscription: Cancellable?
    private var loadingSubscription: Cancellable?
    private var showErrorSubscription: Cancellable?

    // MARK: - UI Elements
    private lazy var sizeMenu: UIMenu = { [unowned self] in
        let menu = UIMenu(title: NSLocalizedString("collection_view_set_size_menu_title", comment: "Select items size"), image: nil, identifier: nil, options: [.displayInline], children: [
            UIAction(title: NSLocalizedString("columns", comment: "Columns"), image: UIImage(systemName: "rectangle.split.3x1"), handler: { (_) in
                self.collectionLayout = .columns
            }),
            UIAction(title: NSLocalizedString("list", comment: "List"), image: UIImage(systemName: "square.fill.text.grid.1x2"), handler: { (_) in
                self.collectionLayout = .list
            })
        ])

        return menu
    }()

    init(viewModel: FavoritesVM) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        collectionView.delegate = self
        loading = true
        viewModel.inputs.fetchMovies()
    }

    override func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("app_name_with_icon", comment: "App name")
    }

    override func bindViewModel() {
        fetchMoviesSubscription = viewModel.outputs.fetchMoviesAction()
            .sink(receiveValue: { [weak self] (movies) in
                guard let movies = movies else { return }

                DispatchQueue.main.async { [weak self] in
                    self?.navigationController?.navigationItem.rightBarButtonItem?.isEnabled = true
                    self?.updateDataSource(movies: movies)
                }
            })

        finishedFetchingSubscription = viewModel.outputs.finishedFetchingAction()
            .sink(receiveValue: { [weak self] (finishedFetching) in
                guard let `self` = self else { return }
                self.finishedFetching = finishedFetching
            })

        showErrorSubscription = viewModel.outputs.showError()
            .sink(receiveValue: { [weak self] errorMessage in
                guard let `self` = self else { return }
                self.handleEmptyView()
                Alert.showAlert(on: self, title: NSLocalizedString("alert", comment: "Alert title"), message: errorMessage)
            })

        movieIncludedSubscription = viewModel.outputs.movieIncludedAction()
            .sink(receiveValue: { [weak self] movie in
                guard let `self` = self else { return }

                var snapshot = self.dataSource.snapshot()
                snapshot.appendItems([movie], toSection: .movies)
                self.dataSource.apply(snapshot, animatingDifferences: true)
                self.handleEmptyView()
            })

        movieRemovedSubscription = viewModel.outputs.movieRemovedAction()
            .sink(receiveValue: { [weak self] movie in
                guard let `self` = self else { return }

                var snapshot = self.dataSource.snapshot()
                snapshot.deleteItems([movie])
                self.dataSource.apply(snapshot, animatingDifferences: true)
                self.handleEmptyView()
            })
    }

    // MARK: - Collection View
    override func updateDataSource(movies: [Movie], animatingDifferences: Bool = true) {
        var snapshot = self.dataSource.snapshot()

        snapshot.appendItems(movies, toSection: .movies)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let `self` = self else { return }

            self.collectionView.removeEmptyView()
            self.setActivityIndicator(active: false)
            self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
            self.loading = false
            self.handleEmptyView()
        }
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }

    override func handleEmptyView() {
        let dataSourceItems = dataSource.snapshot().numberOfItems

        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            if self.loading && dataSourceItems < 1 {
                self.collectionView.setEmptyView(title: NSLocalizedString("loading_movies_title_label", comment: "Loading title"),
                                                 message: NSLocalizedString("loading_movies_description_label", comment: "Loading Message"),
                                                 centeredY: true)

            } else if !self.loading && dataSourceItems < 1 {
                self.collectionView.setEmptyView(title: NSLocalizedString("empty_favorite_movies_title_label", comment: "Empty favorite movie list title"),
                                                 message: NSLocalizedString("empty_favorite_movies_description_label", comment: "Empty favorite movie list message"),
                                                 centeredY: true)
            } else {
                self.collectionView.removeEmptyView()
            }
        }
    }

    // MARK: - ⚙️ Helpers

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑 FavoritesVC deinit.")
    }
}

extension FavoritesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.inputs.movieSelected(movie: movie)
    }
}
