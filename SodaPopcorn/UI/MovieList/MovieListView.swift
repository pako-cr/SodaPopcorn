//
//  ContentView.swift
//  StarWarsWorld
//
//  Created by Zimplifica Macbook Pro on 3/9/21.
//

import SwiftUI

struct MovieListView: View {
	@ObservedObject var viewModel: MovieListViewModel

	var body: some View {
		List {
			if viewModel.datasource.isEmpty {
				emptySection
			} else {
				moviesSection
			}
		}
		.navigationBarTitle("Movies 🍿")
	}
}

private extension MovieListView {
	var moviesSection: some View {
		Section {
			ForEach(viewModel.datasource, content: { movie in
				HStack {
					Image(systemName: "photo")
						.padding()

					VStack(alignment: .leading, spacing: 5) {
						HStack {
							Text("\(movie.title)")
								.font(.headline)
								.bold()

							Spacer()
							Text("\(movie.rating.description)")

						}
						Text("\(movie.overview)")
							.font(.body)
					}
				}
				.padding()
			})
		}
	}

	var emptySection: some View {
		Section {
			Text("No results")
				.foregroundColor(.gray)
		}
	}
}

struct MovieListView_Previews: PreviewProvider {
	static var previews: some View {
		MovieListView(viewModel: MovieListViewModel(networkManager: NetworkManager()))
			.preferredColorScheme(.dark)
	}
}
