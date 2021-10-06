//
//  HomeCoordinator.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 19/9/21.
//

import Foundation
import UIKit

final class HomeCoordinator: Coordinator {
	var childCoordinators = [Coordinator]()
	var navigationController: UINavigationController
	var window: UIWindow

	private let parentViewController: HomeViewController
	private let movieService = MovieService.shared()
//	var homeTabController: HomeViewController?

	init(window: UIWindow) {
		self.parentViewController = HomeViewController()
		self.navigationController = NavigationController(rootViewController: self.parentViewController)
		self.window = window
		self.window.rootViewController = navigationController
		self.window.makeKeyAndVisible()
	}

	func start() {
//		homeTabController = HomeViewController()

		let posterImageViewModel = PosterImageViewModel()
		let newMoviesListViewModel = NewMoviesListViewModel(movieService: movieService, posterImageViewModel: posterImageViewModel)
		let newMoviesListViewController = NewMoviesListViewController(viewModel: newMoviesListViewModel)
		newMoviesListViewController.tabBarItem = UITabBarItem(title: "News", image: UIImage(systemName: "film.fill"), tag: 0)

		parentViewController.viewControllers = [newMoviesListViewController]
		parentViewController.selectedIndex = 0

//		parentViewController.addChild(parentViewController)
//		parentViewController.view.addSubview(parentViewController.view)
//		homeTabController?.didMove(toParent: parentViewController)
	}
}
