//
//  MovieListViewModel.swift
//  StarWarsWorld
//
//  Created by Zimplifica Macbook Pro on 3/9/21.
//

import Foundation
import Combine
import SwiftUI

public protocol MovieListViewModelInputs: AnyObject {
	/// Call to get the new movies.
	func fetchNewMovies()
}

public protocol MovieListViewModelOutputs: AnyObject {
}

public protocol MovieListViewModelTypes: AnyObject {
	var inputs: MovieListViewModelInputs { get }
	var outputs: MovieListViewModelOutputs { get }
}

public final class MovieListViewModel: ObservableObject, Identifiable, MovieListViewModelInputs, MovieListViewModelOutputs, MovieListViewModelTypes {
	// MARK: Constants
	let posterImageViewModel: PosterImageViewModel

	// MARK: Variables
	public var inputs: MovieListViewModelInputs { return self }
	public var outputs: MovieListViewModelOutputs { return self }

	// MARK: Variables
	private var cancellable = Set<AnyCancellable>()

	@Published private (set) var dataSource: [Movie] = []

	init(posterImageViewModel: PosterImageViewModel) {
		self.posterImageViewModel = posterImageViewModel

		self.posterImageViewModel.outputs.fetchPosterImageSignal()
			.sink(receiveValue: { [weak self] (movieInfo) in
				guard let `self` = self else { return }
				self.setPosterImageData(movieId: movieInfo.0, imageData: movieInfo.1)
			}).store(in: &cancellable)

		self.fetchNewMoviesProperty
			.flatMap({ [weak self] _ -> AnyPublisher<[Movie]?, Error> in
				guard let `self` = self else { return Empty(completeImmediately: false).eraseToAnyPublisher() }
				return self.getNewMovies(page: 1)
			})
			.sink(receiveCompletion: { completion in
				switch completion {
					case .failure(let error):
						print("🔴 [MovieListViewModel] [init] Received completion error. Error: \(error.localizedDescription)")
					default: break
				}
			}, receiveValue: { movies in
				if let movies = movies {
					DispatchQueue.main.async {
						self.dataSource = movies
					}
				}
			}).store(in: &cancellable)
	}

	// MARK: - ⬇️ INPUTS Definition
	private let fetchNewMoviesProperty = PassthroughSubject<Void, Never>()
	public func fetchNewMovies() {
		fetchNewMoviesProperty.send(())
	}

	// MARK: - ⬆️ OUTPUTS Definition

	// MARK: - ⚙️ Helpers
	private func getNewMovies(page: Int) -> AnyPublisher<[Movie]?, Error> {
		return MovieService.shared().getNewMovies(page: page)
	}

	private func setPosterImageData(movieId: Int, imageData: Data) {
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
