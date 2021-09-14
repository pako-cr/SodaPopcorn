//
//  Movie.swift
//  StarWarsWorld
//
//  Created by Francisco Cordoba on 3/9/21.
//

import Foundation

public class Movie: Identifiable, Codable {
	public let id: Int
	public let posterPath: String
	public let backdrop: String
	public let title: String
	public let releaseDate: String
	public let rating: Double
	public let overview: String
	public let popularity: Double
	public let voteCount: Int
	public var posterImageData: Data?

	required public init(from decoder: Decoder) throws {
		let movieContainer = try decoder.container(keyedBy: MovieCodingKeys.self)

		id = try movieContainer.decode(Int.self, forKey: .id)
		posterPath = try movieContainer.decode(String.self, forKey: .posterPath)
		backdrop = try movieContainer.decode(String.self, forKey: .backdrop)
		title = try movieContainer.decode(String.self, forKey: .title)
		releaseDate = try movieContainer.decode(String.self, forKey: .releaseDate)
		rating = try movieContainer.decode(Double.self, forKey: .rating)
		overview = try movieContainer.decode(String.self, forKey: .overview)
		popularity = try movieContainer.decode(Double.self, forKey: .popularity)
		voteCount = try movieContainer.decode(Int.self, forKey: .voteCount)
	}

	private init(id: Int, posterPath: String, backdrop: String, title: String, releaseDate: String, rating: Double, overview: String, popularity: Double, voteCount: Int, posterImageData: Data? = nil) {
		self.id = id
		self.posterPath = posterPath
		self.backdrop = backdrop
		self.title = title
		self.releaseDate = releaseDate
		self.rating = rating
		self.overview = overview
		self.popularity = popularity
		self.voteCount = voteCount
		self.posterImageData = posterImageData
	}

	convenience init(movieEntity: MovieEntity) {
		self.init(id: movieEntity.id, posterPath: movieEntity.posterPath, backdrop: movieEntity.backdrop, title: movieEntity.title, releaseDate: movieEntity.releaseDate, rating: movieEntity.rating, overview: movieEntity.overview, popularity: movieEntity.popularity, voteCount: movieEntity.voteCount, posterImageData: movieEntity.posterImageData)
	}
}

extension Movie {
	enum MovieCodingKeys: String, CodingKey {
		case id
		case title
		case overview
		case popularity
		case posterPath  = "poster_path"
		case backdrop    = "backdrop_path"
		case releaseDate = "release_date"
		case rating      = "vote_average"
		case voteCount   = "vote_count"
	}
}

extension Movie: Equatable {
	public static func == (lhs: Movie, rhs: Movie) -> Bool {
		return lhs.id == rhs.id
	}
}
