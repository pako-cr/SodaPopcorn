//
//  NewMoviesListViewModel.swift
//  StarWarsWorld
//
//  Created by Francisco Cordoba on 3/9/21.
//

import Foundation
import Combine
import SwiftUI

public protocol NewMoviesListViewModelInputs: AnyObject {
	/// Call to get the new movies.
	func fetchNewMovies()

	/// Cal to pull to refresh.
	func pullToRefresh()
}

public protocol NewMoviesListViewModelOutputs: AnyObject {
	/// Emits to get the new movies.
	func fetchNewMoviesAction() -> CurrentValueSubject<[Movie]?, Never>

	/// Emits to get return the image.
	func fetchPosterImageSignal() -> PassthroughSubject<(Int, Data), Never>

	/// Emits when loading.
	func loading() -> CurrentValueSubject<Bool, Never>
}

public protocol NewMoviesListViewModelTypes: AnyObject {
	var inputs: NewMoviesListViewModelInputs { get }
	var outputs: NewMoviesListViewModelOutputs { get }
}

public final class NewMoviesListViewModel: ObservableObject, Identifiable, NewMoviesListViewModelInputs, NewMoviesListViewModelOutputs, NewMoviesListViewModelTypes {
	// MARK: Constants
	let posterImageViewModel: PosterImageViewModel
	let movieService: MovieService

	// MARK: Variables
	public var inputs: NewMoviesListViewModelInputs { return self }
	public var outputs: NewMoviesListViewModelOutputs { return self }

	// MARK: Variables
	private var cancellable = Set<AnyCancellable>()
	private var page = 0

	init(movieService: MovieService, posterImageViewModel: PosterImageViewModel) {
		self.movieService = movieService
		self.posterImageViewModel = posterImageViewModel

//		self.posterImageViewModel.outputs.fetchPosterImageSignal()
//			.sink(receiveValue: { [weak self] (movieInfo) in
//				guard let `self` = self else { return }
//				self.setPosterImageData(movieId: movieInfo.0, imageData: movieInfo.1)
//			}).store(in: &cancellable)

		Publishers.Merge(self.fetchNewMoviesProperty, self.pullToRefreshProperty)
			.flatMap({ [weak self] _ -> AnyPublisher<MovieApiResponse?, Error> in
				guard let `self` = self else { return Empty(completeImmediately: false).eraseToAnyPublisher() }
				return self.getNewMovies()
			})
			.sink(receiveCompletion: { completion in
				self.loadingProperty.value = false
				switch completion {
					case .failure(let error):
						print("🔴 [NewMoviesListViewModel] [init] Received completion error. Error: \(error.localizedDescription)")
					default: break
				}
			}, receiveValue: { movieApiResponse in
				self.loadingProperty.value = false
				if let movieApiResponse = movieApiResponse {
					print("🔸 MoviesApiResponse [page: \(movieApiResponse.page), numberOfPages: \(movieApiResponse.numberOfPages), numberOfResults: \(movieApiResponse.numberOfResults)]")
					self.fetchNewMoviesActionProperty.value = movieApiResponse.movies
				}
			}).store(in: &cancellable)
	}

	// MARK: - ⬇️ INPUTS Definition
	private let fetchNewMoviesProperty = PassthroughSubject<Void, Never>()
	public func fetchNewMovies() {
		fetchNewMoviesProperty.send(())
	}

	private let pullToRefreshProperty = PassthroughSubject<Void, Never>()
	public func pullToRefresh() {
		self.page = 0
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
	private func getNewMovies() -> AnyPublisher<MovieApiResponse?, Error> {
		self.page += 1
		self.loadingProperty.value = true
		return movieService.getNewMovies(page: page)
	}

//	private func setPosterImageData(movieId: Int, imageData: Data) {
//		if let index = self.dataSource.firstIndex(where: { $0.id == movieId }) {
//			DispatchQueue.main.async { [weak self] in
//				guard let `self` = self else { return }
//				self.dataSource[index].posterImageData = imageData
//			}
//		}
//	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑", "NewMoviesListViewModel deinit.")
	}
}
