//
//  PosterImage.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 4/9/21.
//

import Combine
import SwiftUI

struct PosterImageView: View {
	private enum LoadState { case loading, success, failure }

	private var viewModel: PosterImageViewModel
	private var loading: Image

	@StateObject private var loader: Loader

	var body: some View {
		selectImage()
			.resizable()
	}

	init(viewModel: PosterImageViewModel, movieId: Int, posterPath: String, loading: Image = Image(uiImage: UIImage(named: "no_poster")!)) {
		_loader = StateObject(wrappedValue: Loader(viewModel: viewModel, movieId: movieId, posterPath: posterPath))
		self.viewModel = viewModel
		self.loading = loading
	}

	private func selectImage() -> Image {
		switch loader.state {
			case .loading, .failure:
				return loading
			case .success:
				if let image = UIImage(data: loader.data) {
					return Image(uiImage: image)
						.resizable()
				} else {
					return loading
				}
		}
	}

	private class Loader: ObservableObject {
		var viewModel: PosterImageViewModel

		var data = Data()
		var state = LoadState.loading

		@State private var cancellable = Set<AnyCancellable>()

		init(viewModel: PosterImageViewModel, movieId: Int, posterPath: String) {
			self.viewModel = viewModel
			self.viewModel.getPosterImage(movieId: movieId, posterPath: posterPath) { data, _ in
				if let data = data, !data.isEmpty {
					self.data = data
					self.state = .success
				} else {
					self.state = .failure
				}

				DispatchQueue.main.async {
					self.objectWillChange.send()
				}
			}
		}
	}
}

struct PosterImageView_Previews: PreviewProvider {
	static var previews: some View {
		PosterImageView(viewModel: PosterImageViewModel(), movieId: 1, posterPath: "oOZITZodAja6optBgLh8ZZrgzbb.jpg")
			.preferredColorScheme(.light)
	}
}
