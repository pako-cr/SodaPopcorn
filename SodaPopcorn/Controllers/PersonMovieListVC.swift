//
//  PersonMovieListVC.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

import Combine
import UIKit

final class PersonMovieListVC: MoviesBaseCollectionView {
    // MARK: - Consts
    private let viewModel: PersonMovieListVM

    // MARK: - Variables
    private var moviesSubscription: Cancellable?
    private var personSubscription: Cancellable?

    // MARK: - UI Elements
    init(viewModel: PersonMovieListVM) {
        self.viewModel = viewModel
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        setupUI()
//        bindViewModel()
        viewModel.inputs.viewDidLoad()
        setupNavigationBar()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .black
    }

    override func setupUI() {
        collectionView.delegate = self
    }

    override func bindViewModel() {
        moviesSubscription = viewModel.outputs.moviesAction()
            .sink(receiveValue: { [weak self] (movies) in
                guard let `self` = self else { return }
                self.updateDataSource(movies: movies)
            })

        personSubscription = viewModel.outputs.personAction()
            .sink(receiveValue: { [weak self] person in
                self?.title = String(format: NSLocalizedString("person_appears_on", comment: "Appears on"), person.name ?? "")
            })
    }

    // MARK: - Collection View
    override func updateDataSource(movies: [Movie], animatingDifferences: Bool = true) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }

            var snapshot = self.dataSource.snapshot()
            snapshot.appendItems(movies, toSection: .movies)

            self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
            self.handleEmptyView()
        }
    }

    override func handleEmptyView() {
        if dataSource.snapshot().numberOfItems < 1 {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.setEmptyView(title: NSLocalizedString("empty_movies_title_label", comment: "Empty list title"),
                                                     message: NSLocalizedString("empty_movies_description_label", comment: "Empty list message"),
                                                     centeredY: true)
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.removeEmptyView()
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }

    // MARK: - ⚙️ Helpers
    @objc
    private func closeButtonPressed() {
        viewModel.inputs.closeButtonPressed()
    }

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑 PersonMovieListVC deinit.")
    }
}

extension PersonMovieListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.inputs.movieSelected(movie: movie)
    }
}
