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

		let viewModel = NowPlayingMoviesVM(movieService: movieService)
		let viewController = NowPlayingMoviesVC(viewModel: viewModel)
        let navigationController = NavigationController(rootViewController: viewController)

        navigationController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "film.fill"), tag: 0)

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

        viewModel.outputs.galleryButtonAction()
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.showGalleryView(with: movie, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.overviewTextAction()
            .sink { [weak self] overview in
                guard let `self` = self else { return }
                self.showCustomLongTextView(with: overview, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.creditsButtonAction()
            .sink { [weak self] (movie, credits) in
                guard let `self` = self else { return }
                self.showCreditsView(with: credits, of: movie, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.castMemberAction()
            .sink { [weak self] person in
                guard let `self` = self else { return }
                self.showPersonDetailsView(with: person, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.movieSelectedAction()
            .sink { [weak self] movie in
                self?.showMovieDetails(movie: movie, with: navigationController)
            }.store(in: &cancellable)
	}

    private func showBackdropImagesView(with imageURL: String, on navigationController: UIViewController) {
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

    private func showGalleryView(with movie: Movie, on navigationController: UINavigationController) {
        let viewModel = GalleryVM(movieService: movieService, movie: movie)
        let viewController = GalleryVC(viewModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.popViewController(animated: true)
            }.store(in: &cancellable)

        viewModel.outputs.backdropImageAction()
            .sink { [weak self] image in
                guard let `self` = self else { return }
                self.showBackdropImagesView(with: image, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.posterImageAction()
            .sink { [weak self] imageUrl in
                guard let `self` = self else { return }
                self.showPosterImageView(with: imageUrl, on: navigationController)
            }.store(in: &cancellable)
    }

    private func showCreditsView(with credits: Credits, of movie: Movie, on navigationController: UINavigationController) {
        let viewModel = CreditsVM(movie: movie, credits: credits)
        let viewController = CreditsVC(viewModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.popViewController(animated: true)
            }.store(in: &cancellable)

        viewModel.outputs.castMemberAction()
            .sink { [weak self] person in
                guard let `self` = self else { return }
                self.showPersonDetailsView(with: person, on: navigationController)
            }.store(in: &cancellable)
    }

    private func showCustomLongTextView(with text: String, on navigationController: UIViewController) {
        let viewModel = CustomLongTextVM(text: text)
        let viewController = CustomLongTextVC(viewModel: viewModel)

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
                self.showCustomLongTextView(with: biography, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.movieSelectedAction()
            .sink { [weak self] movie in
                guard let `self` = self else { return }
                self.showMovieDetails(movie: movie, with: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.personMoviesButtonAction()
            .sink { [weak self] (movies, person) in
                guard let `self` = self else { return }
                self.showPersonMovieList(with: movies, and: person, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.personImageAction()
            .sink { [weak self] personImage in
                guard let `self` = self, let imagePath = personImage.filePath else { return }
                self.showPosterImageView(with: imagePath, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.personGallerySelectedAction()
            .sink { [weak self] (person, images) in
                self?.showPersonGallery(person: person, images: images, with: navigationController)
            }.store(in: &cancellable)
    }

    private func showPersonMovieList(with movies: [Movie], and person: Person, on navigationController: UINavigationController) {
        guard !movies.isEmpty else { return }

        let viewModel = PersonMovieListVM(movies: movies, person: person)
        let viewController = PersonMovieListVC(viewModel: viewModel)

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

        viewModel.outputs.galleryButtonAction()
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                self.showGalleryView(with: movie, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.overviewTextAction()
            .sink { [weak self] overview in
                guard let `self` = self else { return }
                self.showCustomLongTextView(with: overview, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.creditsButtonAction()
            .sink { [weak self] (movie, credits) in
                guard let `self` = self else { return }
                self.showCreditsView(with: credits, of: movie, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.castMemberAction()
            .sink { [weak self] person in
                guard let `self` = self else { return }
                self.showPersonDetailsView(with: person, on: navigationController)
            }.store(in: &cancellable)

        viewModel.outputs.movieSelectedAction()
            .sink { [weak self] movie in
                self?.showMovieDetails(movie: movie, with: navigationController)
            }.store(in: &cancellable)
    }

    private func showPersonGallery(person: Person, images: [PersonImage], with navigationController: UINavigationController) {
        let viewModel = PersonGalleryVM(person: person, personImages: images)
        let viewController = PersonGalleryVC(viewModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.popViewController(animated: true)
            }.store(in: &cancellable)

        viewModel.outputs.imageAction()
            .sink { [weak self] image in
                self?.showPosterImageView(with: image, on: navigationController)
            }.store(in: &cancellable)
    }
}
