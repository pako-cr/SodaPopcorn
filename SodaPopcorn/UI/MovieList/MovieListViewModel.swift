//
//  MovieListViewModel.swift
//  StarWarsWorld
//
//  Created by Zimplifica Macbook Pro on 3/9/21.
//

import Foundation

class MovieListViewModel {
	let networkManager: NetworkManager

	init(networkManager: NetworkManager) {
		print("🟡 [MovieListViewModel] [init]")
		self.networkManager = networkManager

		_ = self.getNewMovies()
	}

	func getNewMovies() -> [Movie]? {
		var movies: [Movie]?
		networkManager.getNewMovies(page: 1) { newMovies, _ in
			print("New movies count: \(newMovies?.count ?? 0)")
			movies = newMovies
		}

		return movies
	}
}
