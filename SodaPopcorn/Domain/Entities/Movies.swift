//
//  Movies.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 6/11/21.
//

public struct Movies {
    let page: Int?
    let numberOfResults: Int?
    let numberOfPages: Int?
    let movies: [Movie]?

    init(page: Int? = nil, numberOfResults: Int? = nil, numberOfPages: Int? = nil, movies: [Movie]? = nil) {
        self.page = page
        self.numberOfResults = numberOfResults
        self.numberOfPages = numberOfPages
        self.movies = movies
    }

    init(apiResponse: MoviesApiResponse) {
        self.init(page: apiResponse.page,
                  numberOfResults: apiResponse.numberOfResults,
                  numberOfPages: apiResponse.numberOfPages,
                  movies: apiResponse.movies?.compactMap({ return !$0.adult ? Movie(apiResponse: $0) : nil }) ?? []) // Remove adult movies
    }
}
