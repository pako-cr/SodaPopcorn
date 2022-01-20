//
//  Movies+ApiInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension Movies {
    public init(apiResponse: MoviesApiResponse) {
        self.init(page: apiResponse.page,
                  numberOfResults: apiResponse.numberOfResults,
                  numberOfPages: apiResponse.numberOfPages,
                  movies: apiResponse.movies?.compactMap({ return !$0.adult ? Movie(apiResponse: $0) : nil }) ?? []) // Remove adult movies
    }
}
