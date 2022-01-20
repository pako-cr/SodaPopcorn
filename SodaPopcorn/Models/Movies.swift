//
//  Movies.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 6/11/21.
//

public struct Movies {
    public let page: Int?
    public let numberOfResults: Int?
    public let numberOfPages: Int?
    public let movies: [Movie]?

    public init(page: Int? = nil, numberOfResults: Int? = nil, numberOfPages: Int? = nil, movies: [Movie]? = nil) {
        self.page = page
        self.numberOfResults = numberOfResults
        self.numberOfPages = numberOfPages
        self.movies = movies
    }
}
