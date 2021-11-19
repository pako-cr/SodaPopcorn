//
//  MoviesVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/9/21.
//

import Combine
import UIKit

final class MoviesVC: MoviesBaseCollectionView {
    // MARK: - Consts
    private let viewModel: MoviesVM

    // MARK: - Variables

    // MARK: Subscriptions
    private var finishedFetchingSubscription: Cancellable!
    private var fetchMoviesSubscription: Cancellable!
    private var loadingSubscription: Cancellable!
    private var showErrorSubscription: Cancellable!

    private var finishedFetching = false

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

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.reloadCollectionView), for: .valueChanged)
        refreshControl.tintColor = UIColor(named: "PrimaryColor")
        return refreshControl
    }()

    init(viewModel: MoviesVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.inputs.fetchMovies()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryColor")
        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    func setupUI() {
        navigationItem.title = NSLocalizedString("app_name_with_icon", comment: "App name")

        if viewModel.presentedViewController {
            let leftBarButtonItemImage = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate)
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftBarButtonItemImage, style: .done, target: self, action: #selector(closeButtonPressed))

        } else {
            let barButtonImage = UIImage(systemName: "square.fill.text.grid.1x2")
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("collection_view_set_layout_button_title", comment: "Set collection layout"), image: barButtonImage, primaryAction: UIAction { _ in self.setCollectionViewLayout() }, menu: sizeMenu)
        }

        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
    }

    func bindViewModel() {
        fetchMoviesSubscription = viewModel.outputs.fetchMoviesAction()
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

    // MARK: - Collection View
    override func updateDataSource(movies: [Movie], animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            if self.reloadingDataSource {
                self.reloadDataSource()
            }

            var snapshot = self.dataSource.snapshot()
            snapshot.appendItems(movies, toSection: .movies)

            self.handleFetchingChange(finishedFetching: false)

            self.loadedCount = snapshot.numberOfItems

            self.collectionView.removeEmptyView()
            self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        }
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

            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ActivityIndicatorFooterReusableView.reuseIdentifier, for: indexPath) as? ActivityIndicatorFooterReusableView
            _ = finishedFetching ? footerView?.stopActivityIndicator() : footerView?.startActivityIndicator()
            return footerView
        }

        self.finishedFetching = finishedFetching
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard loadedCount != 0 else { return }

        if indexPath.row == loadedCount - 1 {
            self.viewModel.inputs.fetchMovies()
        }
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
                self.collectionView.setEmptyView(title: NSLocalizedString("empty_movies_title_label", comment: "Empty list title"),
                                                 message: NSLocalizedString("empty_movies_description_label", comment: "Empty list message"),
                                                 centeredY: true)

            } else {
                self.collectionView.removeEmptyView()
            }
        }
    }

    // MARK: - ⚙️ Helpers
    @objc
    private func closeButtonPressed() {
        viewModel.inputs.closeButtonPressed()
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑 MoviesVC deinit.")
    }
}

extension MoviesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.inputs.movieSelected(movie: movie)
    }
}
