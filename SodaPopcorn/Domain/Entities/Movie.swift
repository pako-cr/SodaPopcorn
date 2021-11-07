//
//  Movie.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/9/21.
//

public final class Movie: Hashable {
    public var id: String?
    public var title: String?
    public var overview: String?
    public var rating: Double?
    public var posterPath: String?
    public var backdropPath: String?
    public var releaseDate: String?
    public var genres: [Genre]?
    public var homepage: String?
    public var runtime: Int?
    public var voteCount: Int?
    public var budget: Int?
    public var revenue: Int?
    public var tagline: String?
    public var productionCompanies: [ProductionCompany]?

    private init(id: String?, title: String?, overview: String?, rating: Double?, posterPath: String?, backdropPath: String?, releaseDate: String?, genres: [Genre]?, homepage: String?, runtime: Int?, voteCount: Int?, budget: Int?, revenue: Int?, tagline: String?, productionCompanies: [ProductionCompany]?) {
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
    }

    convenience init(movieApiResponse: MovieApiResponse) {
        self.init(id: movieApiResponse.id,
                  title: movieApiResponse.title,
                  overview: movieApiResponse.overview,
                  rating: movieApiResponse.rating,
                  posterPath: movieApiResponse.posterPath,
                  backdropPath: movieApiResponse.backdropPath,
                  releaseDate: movieApiResponse.releaseDate,
                  genres: movieApiResponse.genres?.map({ Genre(genreApiResponse: $0) }) ?? [],
                  homepage: movieApiResponse.homepage,
                  runtime: movieApiResponse.runtime,
                  voteCount: movieApiResponse.voteCount,
                  budget: movieApiResponse.budget,
                  revenue: movieApiResponse.revenue,
                  tagline: movieApiResponse.tagline,
                  productionCompanies: movieApiResponse.productionCompanies?.map({ ProductionCompany(productionCompanyApiResponse: $0) }))
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
    }
}
