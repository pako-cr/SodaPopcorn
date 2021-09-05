//
//  ContentView.swift
//  StarWarsWorld
//
//  Created by Zimplifica Macbook Pro on 3/9/21.
//

import Combine
import SwiftUI

struct MovieListView: View {
	@ObservedObject var viewModel: MovieListViewModel

	var body: some View {
		List {
			if self.viewModel.dataSource.isEmpty {
				emptySection
			} else {
				moviesSection
			}
		}
		.navigationBarTitle(Text("Soda Popcorn 🍿"), displayMode: NavigationBarItem.TitleDisplayMode.large)
		.onAppear(perform: {
			viewModel.inputs.fetchNewMovies()
		})
	}
}

private extension MovieListView {
	var moviesSection: some View {
		Section {
			ForEach(viewModel.dataSource, content: { movie in
				HStack(alignment: .center, spacing: 10) {
					if movie.posterImageData?.isEmpty ?? true {
						PosterImageView(viewModel: viewModel.posterImageViewModel, movieId: movie.id, posterPath: movie.posterPath)
							.aspectRatio(contentMode: .fit)
							.frame(width: 80, height: 130, alignment: .center)
							.accessibility(hint: Text("The movie poster"))
							.accessibility(value: Text("The result of the movie poster"))
					} else {
						Image(uiImage: UIImage(data: movie.posterImageData!) ?? UIImage(named: "no_poster")!)
							.aspectRatio(contentMode: .fit)
							.frame(width: 80, height: 130, alignment: .center)
							.accessibility(hint: Text("The movie poster"))
							.accessibility(value: Text("The result of the movie poster"))
					}
					VStack(alignment: .leading, spacing: 0) {
						HStack {
							Text("\(movie.title)")
								.font(.title3)
								.bold()
								.lineLimit(2)
								.accessibility(hint: Text("The movie title"))
								.accessibility(value: Text("The result of the movie title"))
							Spacer()
							Text("\(movie.rating.description)")
								.bold()
								.accessibility(hint: Text("The movie rating"))
								.accessibility(value: Text("The result of the movie rating is \(movie.rating.description) out of 10"))
						}
						Text("\(movie.overview)")
							.font(.caption)
							.lineLimit(5)
							.multilineTextAlignment(.leading)
							.frame(height: 100, alignment: .center)
							.accessibility(hint: Text("The movie overview"))
							.accessibility(value: Text("The result of the movie overview"))
					}
				}
			})
		}
	}

	var emptySection: some View {
		Section {
			Text("No results")
				.accessibility(hint: Text("There are no movies to show"))
				.accessibility(value: Text("The result of the movies"))
		}
	}
}

struct MovieListView_Previews: PreviewProvider {
	static var previews: some View {
		MovieListView(viewModel: MovieListViewModel(posterImageViewModel: PosterImageViewModel()))
			.preferredColorScheme(.light)
	}
}
