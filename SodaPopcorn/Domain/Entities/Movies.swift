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

    convenience init(apiResponse: MoviesApiResponse) {
        self.init(page: apiResponse.page,
                  numberOfResults: apiResponse.numberOfResults,
                  numberOfPages: apiResponse.numberOfPages,
                  movies: apiResponse.movies?.map({ Movie(apiResponse: $0) }) ?? [])
    }

    convenience init() {
        self.init(page: nil, numberOfResults: nil, numberOfPages: nil, movies: nil)
    }
}
