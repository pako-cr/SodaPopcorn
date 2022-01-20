//
//  Movie.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/9/21.
//

import Foundation

public struct Movie: Identifiable, Hashable {
    public let id: String
    public let rating: Double?
    public let genres: [Genre]?
    public let productionCompanies: [ProductionCompany]?
    public let runtime, voteCount, budget, revenue: Int?
    public let movieTitle, overview, posterPath, backdropPath, releaseDate, homepage, tagline, character: String?
    public let adult: Bool?

    public init(id: String, movieTitle: String? = nil, overview: String? = nil, rating: Double? = nil, posterPath: String? = nil, backdropPath: String? = nil, releaseDate: String? = nil, genres: [Genre]? = nil, homepage: String? = nil, runtime: Int? = nil, voteCount: Int? = nil, budget: Int? = nil, revenue: Int? = nil, tagline: String? = nil, productionCompanies: [ProductionCompany]? = nil, character: String? = nil, adult: Bool? = false) {
//        self.id = id
        self.id = id
        self.movieTitle = movieTitle
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
        self.adult = adult
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}
