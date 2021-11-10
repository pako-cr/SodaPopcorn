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

    init(page: Int? = nil, numberOfResults: Int? = nil, numberOfPages: Int? = nil, movies: [Movie]? = nil) {
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
}
