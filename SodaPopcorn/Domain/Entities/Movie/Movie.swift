	//
	//  Movie.swift
	//  StarWarsWorld
	//
	//  Created by Francisco Cordoba on 3/9/21.
	//

import Foundation

public class Movie: Codable, Hashable {
	public let id: String
	public let title: String?
	public let overview: String?
	public let rating: Double?
	public let posterPath: String?
	public var posterImageData: Data?

	private enum MovieCodingKeys: String, CodingKey {
		case id
		case title
		case overview
		case rating      = "vote_average"
		case posterPath  = "poster_path"
	}

	required public init(from decoder: Decoder) throws {
		let movieContainer = try decoder.container(keyedBy: MovieCodingKeys.self)

		id = try String(movieContainer.decode(Int.self, forKey: .id))
		title = try movieContainer.decodeIfPresent(String.self, forKey: .title)
		overview = try movieContainer.decodeIfPresent(String.self, forKey: .overview)
		rating = try movieContainer.decodeIfPresent(Double.self, forKey: .rating)
		posterPath = try movieContainer.decodeIfPresent(String.self, forKey: .posterPath)

	}

	private init(id: String, title: String, overview: String, rating: Double, posterPath: String, posterImageData: Data? = nil) {
		self.id = id
		self.title = title
		self.overview = overview
		self.rating = rating
		self.posterPath = posterPath
		self.posterImageData = posterImageData
	}

	convenience init(movieEntity: MovieEntity) {
		self.init(id: movieEntity.id, title: movieEntity.title, overview: movieEntity.overview, rating: movieEntity.rating, posterPath: movieEntity.posterPath, posterImageData: movieEntity.posterImageData)
	}

	public func hash(into hasher: inout Hasher) {
		return hasher.combine(id)
	}

	public static func == (lhs: Movie, rhs: Movie) -> Bool {
		return lhs.id == rhs.id
	}
}
