//
//  MovieListViewModel.swift
//  StarWarsWorld
//
//  Created by Zimplifica Macbook Pro on 3/9/21.
//

import Foundation
import Combine

public final class MovieListViewModel: ObservableObject, Identifiable {
	// MARK: Constants
	private let networkManager: NetworkManager

	// MARK: Variables
	private var disposables = Set<AnyCancellable>()
	@Published private (set) var datasource: [Movie] = []
//	@Published private (set) var datasource: [Movie] = [
//		Movie(id: 1, posterPath: "path 1", backdrop: "backdrop", title: "Jiu Jitsu", releaseDate: "18/10/2022", rating: 10.0, overview: "Test Overview", popularity: 200.0, voteCount: 3045),
//		Movie(id: 2, posterPath: "path 1", backdrop: "backdrop", title: "Jiu Jitsu", releaseDate: "18/10/2022", rating: 10.0, overview: "Test Overview", popularity: 200.0, voteCount: 3045),
//		Movie(id: 3, posterPath: "path 1", backdrop: "backdrop", title: "Jiu Jitsu", releaseDate: "18/10/2022", rating: 10.0, overview: "Test Overview", popularity: 200.0, voteCount: 3045),
//		Movie(id: 4, posterPath: "path 1", backdrop: "backdrop", title: "Jiu Jitsu", releaseDate: "18/10/2022", rating: 10.0, overview: "Test Overview", popularity: 200.0, voteCount: 3045)
//	]

	init(networkManager: NetworkManager) {
		self.networkManager = networkManager
		self.getNewMovies(page: 1)
	}

	// MARK: - ⚙️ Helpers
	func getNewMovies(page: Int) {
		networkManager.getNewMovies(page: page) { [weak self] responseMovies, _ in
			guard let `self` = self, let newMovies = responseMovies else { return }
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else { return }
				self.datasource = newMovies
			}
		}
	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑", "MovieListViewModel deinit.")
	}

}
