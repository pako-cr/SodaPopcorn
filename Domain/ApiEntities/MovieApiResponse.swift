//
//  MovieApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/9/21.
//

public struct MovieApiResponse: Decodable {
    public let rating: Double?
    public let genres: [GenreApiResponse]?
    public let runtime, voteCount, budget, revenue: Int?
    public let productionCompanies: [ProductionCompanyApiResponse]?
    public let id, title, overview, posterPath, backdropPath, releaseDate, homepage, tagline, character: String?
    public let adult: Bool

    private enum CodingKeys: String, CodingKey {
        case id, title, overview, genres, homepage, runtime, budget, revenue, tagline, character, adult
        case rating               = "vote_average"
        case posterPath           = "poster_path"
        case backdropPath         = "backdrop_path"
        case releaseDate          = "release_date"
        case voteCount            = "vote_count"
        case productionCompanies  = "production_companies"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try String(container.decode(Int.self, forKey: .id))
        title = try container.decodeIfPresent(String.self, forKey: .title)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        genres = try container.decodeIfPresent([GenreApiResponse].self, forKey: .genres)
        homepage = try container.decodeIfPresent(String.self, forKey: .homepage)
        runtime = try container.decodeIfPresent(Int.self, forKey: .runtime)
        voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount)
        budget = try container.decodeIfPresent(Int.self, forKey: .budget)
        revenue = try container.decodeIfPresent(Int.self, forKey: .revenue)
        tagline = try container.decodeIfPresent(String.self, forKey: .tagline)
        productionCompanies = try container.decodeIfPresent([ProductionCompanyApiResponse].self, forKey: .productionCompanies)
        character = try container.decodeIfPresent(String.self, forKey: .character)
        adult = try container.decode(Bool.self, forKey: .adult)
    }
}
