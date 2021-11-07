//
//  Movies.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 6/11/21.
//

public final class Movies {
    var page: Int?
    var numberOfResults: Int?
    var numberOfPages: Int?
    var movies: [Movie]?

    private init(page: Int?, numberOfResults: Int?, numberOfPages: Int?, movies: [Movie]?) {
        self.page = page
        self.numberOfResults = numberOfResults
        self.numberOfPages = numberOfPages
        self.movies = movies
    }

    convenience init(moviesApiResponse: MoviesApiResponse) {
        self.init(page: moviesApiResponse.page,
                  numberOfResults: moviesApiResponse.numberOfResults,
                  numberOfPages: moviesApiResponse.numberOfPages,
                  movies: moviesApiResponse.movies?.map({ Movie(movieApiResponse: $0) }) ?? [])
    }

    convenience init() {
        self.init(page: nil, numberOfResults: nil, numberOfPages: nil, movies: nil)
    }
}
