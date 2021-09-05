//
//  PosterImageViewModel.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 5/9/21.
//

import Combine
import Foundation

final class PosterImageViewModel: ObservableObject, Identifiable {
	// MARK: Constants
	private let posterInfoSubject: PassthroughSubject<(Int, Data)?, Never>

	// MARK: Variables
	@Published private (set) var posterInfo: (Int, Data)?

	init() {
		posterInfoSubject = PassthroughSubject<(Int, Data)?, Never>()
	}

	// MARK: - ⚙️ Helpers
	func getPosterImage(movieId: Int, posterPath: String, completion: @escaping (_ imageData: Data?, _ error: String?) -> Void) {
		PosterImageService.shared().getPosterImage(posterPath: posterPath) { [weak self] data, error in
			completion(data, error)

			guard let `self` = self, let data = data, !data.isEmpty else { return }
			self.posterInfo = (movieId, data)
//			self.posterInfo?.append((movieId, data))
		}
	}

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑", "PosterImageViewModel deinit.")
	}

}
