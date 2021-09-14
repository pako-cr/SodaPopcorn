//
//  MovieListViewModel.swift
//  StarWarsWorld
//
//  Created by Francisco Cordoba on 3/9/21.
//

import Foundation
import Combine
import SwiftUI

public protocol MovieListViewModelInputs: AnyObject {
	/// Call when view did load.
	func viewDidLoad()

	/// Call to get the new movies.
	func fetchNewMovies()

	/// Cal to pull to refresh.
	func pullToRefresh()
}

public protocol MovieListViewModelOutputs: AnyObject {
	/// Emits to get the new movies.
	func fetchNewMoviesAction() -> CurrentValueSubject<[Movie]?, Never>

	/// Emits to get return the image.
	func fetchPosterImageSignal() -> PassthroughSubject<(Int, Data), Never>

	/// Emits when loading.
	func loading() -> CurrentValueSubject<Bool, Never>
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
	private var page = 0

	@Published private (set) var dataSource: [Movie] = []

	init(posterImageViewModel: PosterImageViewModel) {
		self.posterImageViewModel = posterImageViewModel

		self.posterImageViewModel.outputs.fetchPosterImageSignal()
			.sink(receiveValue: { [weak self] (movieInfo) in
				guard let `self` = self else { return }
				self.setPosterImageData(movieId: movieInfo.0, imageData: movieInfo.1)
			}).store(in: &cancellable)

		Publishers.Merge3(self.viewDidLoadProperty, self.fetchNewMoviesProperty, self.pullToRefreshProperty)
			.flatMap({ [weak self] _ -> AnyPublisher<[Movie]?, Error> in
				guard let `self` = self else { return Empty(completeImmediately: false).eraseToAnyPublisher() }
				self.page += 1
				return self.getNewMovies(page: self.page)
			})
			.sink(receiveCompletion: { completion in
				switch completion {
					case .failure(let error):
						print("🔴 [MovieListViewModel] [init] Received completion error. Error: \(error.localizedDescription)")
					default: break
				}
			}, receiveValue: { movies in
				if let movies = movies {
					self.fetchNewMoviesActionProperty.value = movies
					self.dataSource = movies
				}
			}).store(in: &cancellable)
	}

	// MARK: - ⬇️ INPUTS Definition
	private let fetchNewMoviesProperty = PassthroughSubject<Void, Never>()
	public func fetchNewMovies() {
		fetchNewMoviesProperty.send(())
	}

	private let viewDidLoadProperty = PassthroughSubject<Void, Never>()
	public func viewDidLoad() {
		viewDidLoadProperty.send(())
	}

	private let pullToRefreshProperty = PassthroughSubject<Void, Never>()
	public func pullToRefresh() {
		self.page = 1
		pullToRefreshProperty.send(())
	}

	// MARK: - ⬆️ OUTPUTS Definition
	private let fetchNewMoviesActionProperty = CurrentValueSubject<[Movie]?, Never>([])
	public func fetchNewMoviesAction() -> CurrentValueSubject<[Movie]?, Never> {
		return fetchNewMoviesActionProperty
	}

	private var fetchPosterImageSignalProperty = PassthroughSubject<(Int, Data), Never>()
	public func fetchPosterImageSignal() -> PassthroughSubject<(Int, Data), Never> {
		return fetchPosterImageSignalProperty
	}

	private var loadingProperty = CurrentValueSubject<Bool, Never>(false)
	public func loading() -> CurrentValueSubject<Bool, Never> {
		return loadingProperty
	}

	// MARK: - ⚙️ Helpers
	private func getNewMovies(page: Int) -> AnyPublisher<[Movie]?, Error> {
		self.loadingProperty.value = true

		let event = MovieService.shared().getNewMovies(page: page)

		event
			.subscribe(on: DispatchQueue.main)
			.sink(receiveCompletion: { _ in
				self.loadingProperty.value = false
			}, receiveValue: { _ in

			}).store(in: &cancellable)

		return event
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
