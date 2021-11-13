//
//  HomeCoordinator.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 19/9/21.
//

import Combine
import Foundation
import UIKit

final class HomeCoordinator: Coordinator {
	// MARK: - Const
	private let parentViewController: UIViewController
	private let movieService = MovieService.shared()

	// MARK: - Vars
	var childCoordinators = [Coordinator]()
	private var homeVC: HomeVC?
	private var window: UIWindow

	private var cancellable = Set<AnyCancellable>()

	init(window: UIWindow) {
		self.parentViewController = BaseViewController()

		self.window = window
		self.window.rootViewController = parentViewController
		self.window.makeKeyAndVisible()

		_ = Reachability.signalProducer.sink { reachability in
			switch reachability {
				case .none:
					if let rootViewController = self.window.rootViewController {
						Alert.showAlert(on: rootViewController, title: NSLocalizedString("alert", comment: "Alert"), message: NSLocalizedString("no_internet_connection", comment: "No internet connection"))
					}
				default:
					break
			}
		}
	}

    func start() {
		self.homeVC = HomeVC()

		let viewModel = NewMoviesListVM(movieService: movieService)
		let viewController = NewMoviesListVC(viewModel: viewModel)
        let navigationController = NavigationController(rootViewController: viewController)

        navigationController.tabBarItem = UITabBarItem(title: "New Movies", image: UIImage(systemName: "film.fill"), tag: 0)

		homeVC?.viewControllers = [navigationController]
		homeVC?.selectedIndex = 0
        homeVC?.tabBar.tintColor = UIColor(named: "PrimaryColor")

		parentViewController.addChild(homeVC!)
		parentViewController.view.addSubview(homeVC!.view)
		homeVC!.didMove(toParent: parentViewController)

		viewModel.outputs.movieSelectedAction()
			.sink { [weak self] movie in
				guard let `self` = self else { return }
                self.showMovieDetails(movie: movie, on: navigationController)
			}.store(in: &cancellable)
	}

	private func showMovieDetails(movie: Movie, on baseViewController: UIViewController) {
        let viewModel = MovieDetailsVM(movieService: movieService, movie: movie)
		let viewController = MovieDetailsVC(viewModel: viewModel)

        let navigationController = NavigationController(rootViewController: viewController)
        baseViewController.present(navigationController, animated: true, completion: nil)

		viewModel.outputs.closeButtonAction()
			.sink { _ in
                baseViewController.dismiss(animated: true, completion: nil)
			}.store(in: &cancellable)

        viewModel.outputs.backdropImageAction()
            .sink { [weak self] (imageURL) in
                guard let `self` = self else { return }
                self.showBackdropImageView(with: imageURL, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.galleryButtonAction()
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.showGalleryView(with: movie, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.overviewTextAction()
            .sink { [weak self] overview in
                guard let `self` = self else { return }
                self.showCustomTextView(with: overview, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.creditsButtonAction()
            .sink { [weak self] credits in
                guard let `self` = self else { return }
                self.showCreditsView(with: credits, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.castMemberAction()
            .sink { [weak self] person in
                guard let `self` = self else { return }
                self.showPersonDetailsView(with: person, on: navigationController)
            }.store(in: &cancellable)
	}

    private func showBackdropImageView(with imageURL: String, on navigationController: UIViewController) {
        let viewModel = BackdropImageVM(imageURL: imageURL)
        let viewController = BackdropImageVC(viewModel: viewModel)

        navigationController.present(viewController, animated: true, completion: nil)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.dismiss(animated: true, completion: nil)
            }.store(in: &cancellable)
    }

    private func showPosterImageView(with imageURL: String, on navigationController: UIViewController) {
        let viewModel = PosterImageVM(imageURL: imageURL)
        let viewController = PosterImageVC(viewModel: viewModel)

        navigationController.present(viewController, animated: true, completion: nil)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.dismiss(animated: true, completion: nil)
            }.store(in: &cancellable)
    }

    private func showGalleryView(with movie: Movie, on navigationController: UIViewController) {
        let viewModel = GalleryVM(movieService: movieService, movie: movie)
        let viewController = GalleryVC(viewModel: viewModel)

        navigationController.present(viewController, animated: true, completion: nil)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.dismiss(animated: true, completion: nil)
            }.store(in: &cancellable)

        viewModel.outputs.backdropImageAction()
            .sink { [weak self] imageUrl in
                guard let `self` = self, let presentedVC = navigationController.presentedViewController else { return }
                self.showBackdropImageView(with: imageUrl, on: presentedVC)
            }.store(in: &cancellable)

        viewModel.outputs.posterImageAction()
            .sink { [weak self] imageUrl in
                guard let `self` = self, let presentedVC = navigationController.presentedViewController else { return }
                self.showPosterImageView(with: imageUrl, on: presentedVC)
            }.store(in: &cancellable)
    }

    private func showCreditsView(with credits: Credits, on navigationController: UINavigationController) {
        let viewModel = CreditsVM(movieService: movieService, credits: credits)
        let viewController = CreditsVC(viewModel: viewModel)

//        navigationController.present(viewController, animated: true, completion: nil)
        navigationController.pushViewController(viewController, animated: true)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
//                navigationController.dismiss(animated: true, completion: nil)
                navigationController.popViewController(animated: true)
            }.store(in: &cancellable)

        viewModel.outputs.castMemberAction()
            .sink { [weak self] person in
                guard let `self` = self else { return }
                self.showPersonDetailsView(with: person, on: navigationController)
            }.store(in: &cancellable)
    }

    private func showCustomTextView(with text: String, on navigationController: UIViewController) {
        let viewModel = CustomTextVM(text: text)
        let viewController = CustomTextVC(viewModel: viewModel)

        navigationController.present(viewController, animated: true, completion: nil)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.dismiss(animated: true, completion: nil)
            }.store(in: &cancellable)
    }

    private func showPersonDetailsView(with person: Person, on navigationController: UINavigationController) {
        let viewModel = PersonDetailsVM(movieService: movieService, person: person)
        let viewController = PersonDetailsVC(viewModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.popViewController(animated: true)
            }.store(in: &cancellable)

        viewModel.outputs.biographyTextAction()
            .sink { [weak self] biography in
                guard let `self` = self else { return }
                self.showCustomTextView(with: biography, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.movieSelectedAction()
            .sink { [weak self] movie in
                guard let `self` = self else { return }
                self.showMovieDetails(movie: movie, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.personMoviesButtonAction()
            .sink { [weak self] (movies, person) in
                guard let `self` = self else { return }
                self.showMovieList(with: movies, and: person, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.personImageAction()
            .sink { [weak self] personImage in
                guard let `self` = self, let imagePath = personImage.filePath else { return }
                self.showPosterImageView(with: imagePath, on: navigationController)
            }.store(in: &cancellable)
    }

    private func showMovieList(with movies: [Movie], and person: Person, on navigationController: UINavigationController) {
        guard !movies.isEmpty else { return }

        let viewModel = MoviesListVM(movies: movies, person: person)
        let viewController = MoviesListVC(viewModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)

        viewModel.outputs.movieSelectedAction()
            .sink { [weak self] movie in
                guard let `self` = self else { return }
                self.showMovieDetails(movie: movie, with: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.popViewController(animated: true)
            }.store(in: &cancellable)
    }

    private func showMovieDetails(movie: Movie, with navigationController: UINavigationController) {
        let viewModel = MovieDetailsVM(movieService: movieService, movie: movie)
        let viewController = MovieDetailsVC(viewModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.popViewController(animated: true)
            }.store(in: &cancellable)

        viewModel.outputs.backdropImageAction()
            .sink { [weak self] (imageURL) in
                guard let `self` = self else { return }
                self.showBackdropImageView(with: imageURL, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.galleryButtonAction()
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.showGalleryView(with: movie, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.overviewTextAction()
            .sink { [weak self] overview in
                guard let `self` = self else { return }
                self.showCustomTextView(with: overview, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.creditsButtonAction()
            .sink { [weak self] credits in
                guard let `self` = self else { return }
                self.showCreditsView(with: credits, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.castMemberAction()
            .sink { [weak self] person in
                guard let `self` = self else { return }
                self.showPersonDetailsView(with: person, on: navigationController)
            }.store(in: &cancellable)
    }
}
