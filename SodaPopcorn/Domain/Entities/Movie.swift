//
//  Movie.swift
//  StarWarsWorld
//
//  Created by Francisco Cordoba on 3/9/21.
//

import Foundation

public final class Movie: Codable, Hashable {
	public var id: String?
	public var title: String?
	public var overview: String?
	public var rating: Double?
	public var posterPath: String?
	public var backdropPath: String?
	public var posterImageData: Data?
    public var releaseDate: String?
    public var genres: [Genre]?
    public var homepage: String?
    public var runtime: Int?
    public var video: Bool?
    public var voteCount: Int?
    public var budget: Int?
    public var revenue: Int?
    public var productionCountries: [ProductionCountry]?
    public var tagline: String?
    public var spokenLanguages: [SpokenLanguage]?
    public var productionCompanies: [ProductionCompany]?

	private enum MovieCodingKeys: String, CodingKey {
		case id
		case title
		case overview
		case rating      	      = "vote_average"
		case posterPath  	      = "poster_path"
		case backdropPath	      = "backdrop_path"
        case releaseDate          = "release_date"
        case genres
        case homepage
        case runtime
        case video
        case voteCount            = "vote_count"
        case budget
        case revenue
        case productionCountries  = "production_countries"
        case tagline
        case spokenLanguages      = "spoken_languages"
        case productionCompanies  = "production_companies"
	}

	required public init(from decoder: Decoder) throws {
		let movieContainer = try decoder.container(keyedBy: MovieCodingKeys.self)

		id = try String(movieContainer.decode(Int.self, forKey: .id))
		title = try movieContainer.decodeIfPresent(String.self, forKey: .title)
		overview = try movieContainer.decodeIfPresent(String.self, forKey: .overview)
		rating = try movieContainer.decodeIfPresent(Double.self, forKey: .rating)
		posterPath = try movieContainer.decodeIfPresent(String.self, forKey: .posterPath)
		backdropPath = try movieContainer.decodeIfPresent(String.self, forKey: .backdropPath)
        releaseDate = try movieContainer.decodeIfPresent(String.self, forKey: .releaseDate)
        genres = try movieContainer.decodeIfPresent([Genre].self, forKey: .genres)
        homepage = try movieContainer.decodeIfPresent(String.self, forKey: .homepage)
        runtime = try movieContainer.decodeIfPresent(Int.self, forKey: .runtime)
        video = try movieContainer.decodeIfPresent(Bool.self, forKey: .video)
        voteCount = try movieContainer.decodeIfPresent(Int.self, forKey: .voteCount)
        budget = try movieContainer.decodeIfPresent(Int.self, forKey: .budget)
        revenue = try movieContainer.decodeIfPresent(Int.self, forKey: .revenue)
        productionCountries = try movieContainer.decodeIfPresent([ProductionCountry].self, forKey: .productionCountries)
        tagline = try movieContainer.decodeIfPresent(String.self, forKey: .tagline)
        spokenLanguages = try movieContainer.decodeIfPresent([SpokenLanguage].self, forKey: .spokenLanguages)
        productionCompanies = try movieContainer.decodeIfPresent([ProductionCompany].self, forKey: .productionCompanies)
	}

	public func hash(into hasher: inout Hasher) {
		return hasher.combine(id)
	}

	public static func == (lhs: Movie, rhs: Movie) -> Bool {
		return lhs.id == rhs.id
	}
}
