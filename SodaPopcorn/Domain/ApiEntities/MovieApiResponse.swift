//
//  MovieApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/9/21.
//

public final class MovieApiResponse: Codable {
    public var id: String?
    public var title: String?
    public var overview: String?
    public var rating: Double?
    public var posterPath: String?
    public var backdropPath: String?
    public var releaseDate: String?
    public var genres: [GenreApiResponse]?
    public var homepage: String?
    public var runtime: Int?
    public var voteCount: Int?
    public var budget: Int?
    public var revenue: Int?
    public var tagline: String?
    public var productionCompanies: [ProductionCompanyApiResponse]?

    private enum MovieApiResponseCodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case genres
        case homepage
        case runtime
        case budget
        case revenue
        case tagline
        case rating               = "vote_average"
        case posterPath           = "poster_path"
        case backdropPath         = "backdrop_path"
        case releaseDate          = "release_date"
        case voteCount            = "vote_count"
        case productionCompanies  = "production_companies"
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: MovieApiResponseCodingKeys.self)

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
    }
}
