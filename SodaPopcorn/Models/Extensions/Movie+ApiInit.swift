//
//  Movie+ConvenienceInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension Movie {
    public init(apiResponse: MovieApiResponse) {
        self.init(id: apiResponse.id ?? UUID().uuidString,
                  movieTitle: apiResponse.movieTitle,
                  overview: apiResponse.overview,
                  rating: apiResponse.rating,
                  posterPath: apiResponse.posterPath,
                  backdropPath: apiResponse.backdropPath,
                  releaseDate: apiResponse.releaseDate,
                  genres: apiResponse.genres?.map({ Genre(apiResponse: $0) }) ?? [],
                  homepage: apiResponse.homepage,
                  runtime: apiResponse.runtime,
                  voteCount: apiResponse.voteCount,
                  budget: apiResponse.budget,
                  revenue: apiResponse.revenue,
                  tagline: apiResponse.tagline,
                  productionCompanies: apiResponse.productionCompanies?.map({ ProductionCompany(apiResponse: $0) }),
                  character: apiResponse.character,
                  adult: apiResponse.adult
        )
    }
}
