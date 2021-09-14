//
//  PosterImageViewModel.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/9/21.
//

import Combine
import Foundation

public protocol PosterImageViewModelInputs: AnyObject {
}

public protocol PosterImageViewModelOutputs: AnyObject {
	/// Emits to return the poster image data.
	func fetchPosterImageSignal() -> PassthroughSubject<(Int, Data), Never>
}

public protocol PosterImageViewModelTypes: AnyObject {
	var inputs: PosterImageViewModelInputs { get }
	var outputs: PosterImageViewModelOutputs { get }
}

final class PosterImageViewModel: PosterImageViewModelInputs, PosterImageViewModelOutputs, PosterImageViewModelTypes {
	// MARK: Constants

	// MARK: Variables
	public var inputs: PosterImageViewModelInputs { return self }
	public var outputs: PosterImageViewModelOutputs { return self }

	init() {
	}

	// MARK: - ⬇️ INPUTS Definition

	// MARK: - ⬆️ OUTPUTS Definition
	private var fetchPosterImageSignalProperty = PassthroughSubject<(Int, Data), Never>()
	public func fetchPosterImageSignal() -> PassthroughSubject<(Int, Data), Never> {
		return fetchPosterImageSignalProperty
	}

	// MARK: - ⚙️ Helpers
	public func getPosterImage(movie: Movie, posterPath: String, completion: @escaping (_ imageData: Data?, _ error: String?) -> Void) {
		PosterImageService.shared().getPosterImage(posterPath: posterPath, posterSize: PosterSize.w154) { [weak self] data, error in
			completion(data, error)

			guard let `self` = self, let data = data, !data.isEmpty else { return }
			self.fetchPosterImageSignalProperty.send((movie.id, data))

//			movie.posterImageData = data
//			do {
//				try MovieService.shared().update(movie: movie)
//			} catch {
//
//			}
		}
	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑", "PosterImageViewModel deinit.")
	}

}
