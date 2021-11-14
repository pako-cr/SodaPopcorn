//
//  Movie.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/9/21.
//

public struct Movie: Hashable {
    let rating: Double?
    let genres: [Genre]?
    let productionCompanies: [ProductionCompany]?
    let runtime, voteCount, budget, revenue: Int?
    let id, title, overview, posterPath, backdropPath, releaseDate, homepage, tagline, character: String?

    init(id: String? = nil, title: String? = nil, overview: String? = nil, rating: Double? = nil, posterPath: String? = nil, backdropPath: String? = nil, releaseDate: String? = nil, genres: [Genre]? = nil, homepage: String? = nil, runtime: Int? = nil, voteCount: Int? = nil, budget: Int? = nil, revenue: Int? = nil, tagline: String? = nil, productionCompanies: [ProductionCompany]? = nil, character: String? = nil) {
        self.id = id
        self.title = title
        self.overview = overview
        self.rating = rating
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.genres = genres
        self.homepage = homepage
        self.runtime = runtime
        self.voteCount = voteCount
        self.budget = budget
        self.revenue = revenue
        self.tagline = tagline
        self.productionCompanies = productionCompanies
        self.character = character
    }

    init(apiResponse: MovieApiResponse) {
        self.init(id: apiResponse.id,
                  title: apiResponse.title,
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
                  character: apiResponse.character
        )
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}
