//
//  SearchVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/11/21.
//

import Combine
import UIKit

final class SearchVC: BaseViewController {
    // MARK: - Consts
    private let viewModel: SearchVM

    // MARK: - Variables

    // MARK: Subscriptions
    private var finishedFetchingSubscription: Cancellable!
    private var fetchMoviesSubscription: Cancellable!
    private var loadingSubscription: Cancellable!
    private var showErrorSubscription: Cancellable!

    // MARK: - UI Elements
    private let searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.isActive = true
        searchController.becomeFirstResponder()
        return searchController
    }()

    private let searchImage: UIImageView = {
        let uiImage = UIImage(systemName: "magnifyingglass.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(UIColor(named: "PrimaryColor")!)
        let uiImageView = UIImageView(image: uiImage)
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        return uiImageView
    }()

    private let searchHeaderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.maximumContentSizeCategory = .accessibilityMedium
        label.text = NSLocalizedString("search_title", comment: "Search title")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()

    init(viewModel: SearchVM) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        navigationController?.navigationBar.tintColor = UIColor(named: "PrimaryColor")
        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    override func setupUI() {
        view.addSubview(searchImage)
        view.addSubview(searchHeaderLabel)

        searchImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        searchImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchImage.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true
        searchImage.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true

        searchHeaderLabel.topAnchor.constraint(equalTo: searchImage.bottomAnchor, constant: 10).isActive = true
        searchHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        searchHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        searchHeaderLabel.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1).isActive = true
    }

    private func setupNavigationBar() {
        navigationItem.searchController = searchController
    }

    override func bindViewModel() {
//        fetchMoviesSubscription = viewModel.outputs.fetchNewMoviesAction()
//            .filter({ !($0?.isEmpty ?? true) })
//            .sink(receiveValue: { [weak self] (movies) in
//                guard let `self` = self, let movies = movies, !movies.isEmpty else { return }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
//                    self?.updateDataSource(movies: movies)
//                }
//            })
//
//        loadingSubscription = viewModel.outputs.loading()
//            .sink(receiveValue: { [weak self] (loading) in
//                guard let `self` = self else { return }
//                self.loading = loading
//            })
//
//        finishedFetchingSubscription = viewModel.outputs.finishedFetchingAction()
//            .sink(receiveValue: { [weak self] (finishedFetching) in
//                guard let `self` = self else { return }
//
//                if self.finishedFetching != finishedFetching {
//                    self.handleFetchingChange(finishedFetching: finishedFetching)
//                }
//            })

//        showErrorSubscription = viewModel.outputs.showError()
//            .sink(receiveValue: { [weak self] errorMessage in
//                guard let `self` = self else { return }
//                self.handleEmptyView()
//                Alert.showAlert(on: self, title: NSLocalizedString("alert", comment: "Alert title"), message: errorMessage)
//            })
    }

    // MARK: - ⚙️ Helpers

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑 SearchVC deinit.")
    }
}
