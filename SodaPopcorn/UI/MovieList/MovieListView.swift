//
//  ContentView.swift
//  StarWarsWorld
//
//  Created by Zimplifica Macbook Pro on 3/9/21.
//

import SwiftUI

struct MovieListView: View {
	var viewModel: MovieListViewModel

    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
		MovieListView(viewModel: MovieListViewModel(networkManager: NetworkManager()))
    }
}
