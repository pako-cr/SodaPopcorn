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

		let newMoviesListVM = NewMoviesListVM(movieService: movieService)
		let newMoviesListViewController = NavigationController(rootViewController: NewMoviesListVC(viewModel: newMoviesListVM))
		newMoviesListViewController.tabBarItem = UITabBarItem(title: "New Movies", image: UIImage(systemName: "film.fill"), tag: 0)

		homeVC?.viewControllers = [newMoviesListViewController]
		homeVC?.selectedIndex = 0
        homeVC?.tabBar.tintColor = UIColor(named: "PrimaryColor")

		parentViewController.addChild(homeVC!)
		parentViewController.view.addSubview(homeVC!.view)
		homeVC!.didMove(toParent: parentViewController)

		newMoviesListVM.outputs.movieSelectedAction()
			.sink { [weak self] movie in
				guard let `self` = self else { return }
                self.showMovieDetails(movie: movie, on: self.homeVC!)
			}.store(in: &cancellable)
	}

	private func showMovieDetails(movie: Movie, on navigationController: UIViewController) {
        let viewModel = MovieDetailsVM(movieService: movieService, movie: movie)
		let viewController = MovieDetailsVC(viewModel: viewModel)

        navigationController.present(viewController, animated: true, completion: nil)

		viewModel.outputs.closeButtonAction()
			.sink { _ in
                navigationController.dismiss(animated: true, completion: nil)
			}.store(in: &cancellable)

        viewModel.outputs.backdropImageAction()
            .sink { [weak self] (imageURL) in
                guard let `self` = self, let presentedVC = navigationController.presentedViewController else { return }
                self.showBackdropImageView(with: imageURL, on: presentedVC)
            }.store(in: &cancellable)

        viewModel.outputs.galleryButtonAction()
            .sink { [weak self] _ in
                guard let `self` = self, let presentedVC = navigationController.presentedViewController else { return }
                self.showGalleryView(with: movie, on: presentedVC)
            }.store(in: &cancellable)

        viewModel.outputs.overviewTextAction()
            .sink { [weak self] overview in
                guard let `self` = self, let presentedVC = navigationController.presentedViewController else { return }
                self.showCustomTextView(with: overview, on: presentedVC)
            }.store(in: &cancellable)

        viewModel.outputs.creditsButtonAction()
            .sink { [weak self] credits in
                guard let `self` = self, let presentedVC = navigationController.presentedViewController else { return }
                self.showCreditsView(with: credits, on: presentedVC)
            }.store(in: &cancellable)

        viewModel.outputs.castMemberAction()
            .sink { [weak self] person in
                guard let `self` = self, let presentedVC = navigationController.presentedViewController else { return }
                self.showPersonDetailsView(with: person, on: presentedVC)
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

    private func showCreditsView(with credits: Credits, on navigationController: UIViewController) {
        let viewModel = CreditsVM(movieService: movieService, credits: credits)
        let viewController = CreditsVC(viewModel: viewModel)

        navigationController.present(viewController, animated: true, completion: nil)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.dismiss(animated: true, completion: nil)
            }.store(in: &cancellable)

        viewModel.outputs.castMemberAction()
            .sink { [weak self] person in
                guard let `self` = self, let presentedVC = navigationController.presentedViewController else { return }
                self.showPersonDetailsView(with: person, on: presentedVC)
            }.store(in: &cancellable)
    }

    public func showCustomTextView(with text: String, on navigationController: UIViewController) {
        let viewModel = CustomTextVM(text: text)
        let viewController = CustomTextVC(viewModel: viewModel)

        navigationController.present(viewController, animated: true, completion: nil)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.dismiss(animated: true, completion: nil)
            }.store(in: &cancellable)
    }

    public func showPersonDetailsView(with person: Person, on navigationController: UIViewController) {
        let viewModel = PersonDetailsVM(movieService: movieService, person: person)
        let viewController = PersonDetailsVC(viewModel: viewModel)

        navigationController.present(viewController, animated: true, completion: nil)

        viewModel.outputs.closeButtonAction()
            .sink { _ in
                navigationController.dismiss(animated: true, completion: nil)
            }.store(in: &cancellable)

        viewModel.outputs.biographyTextAction()
            .sink { [weak self] biography in
                guard let `self` = self, let presentedVC = navigationController.presentedViewController else { return }
                self.showCustomTextView(with: biography, on: presentedVC)
            }.store(in: &cancellable)

        viewModel.outputs.movieSelectedAction()
            .sink { [weak self] movie in
                guard let `self` = self, let presentedVC = navigationController.presentedViewController else { return }
                self.showMovieDetails(movie: movie, on: presentedVC)
            }.store(in: &cancellable)

        viewModel.outputs.personMoviesButtonAction()
            .sink { [weak self] movies in
                guard let `self` = self, let presentedVC = navigationController.presentedViewController else { return }
                print("Showing all person movies: \n \(movies)")
            }.store(in: &cancellable)
    }
}
