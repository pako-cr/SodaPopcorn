//
//  MovieListViewModel.swift
//  StarWarsWorld
//
//  Created by Zimplifica Macbook Pro on 3/9/21.
//

import Foundation
import Combine
import SwiftUI

public final class MovieListViewModel: ObservableObject {
	// MARK: Constants
	@ObservedObject var posterImageViewModel = PosterImageViewModel()

	// MARK: Variables
	@Published private (set) var dataSource: [Movie] = []
	private var cancellables = Set<AnyCancellable>()

	init() {
		self.getNewMovies(page: 1)

		_ = self.posterImageViewModel.$posterInfo
			.subscribe(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] movieInfo in
				guard let `self` = self, let movieId = movieInfo?.0, let imageData = movieInfo?.1 else { return }
				self.setPosterImageData(movieId: movieId, imageData: imageData)
			})
	}

	// MARK: - ⚙️ Helpers
	private func getNewMovies(page: Int) {
		MovieService.shared().getNewMovies(page: page) { [weak self] responseMovies, _ in
			guard let `self` = self, let newMovies = responseMovies else { return }
			DispatchQueue.main.async { [weak self] in
				self?.dataSource = newMovies
			}
		}
	}

	func setPosterImageData(movieId: Int, imageData: Data) {
		if let index = self.dataSource.firstIndex(where: { $0.id == movieId }) {
			DispatchQueue.main.async { [weak self] in
				guard let `self` = self else { return }
				self.dataSource[index].posterImageData = imageData
			}
		}
	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑", "MovieListViewModel deinit.")
	}
}
