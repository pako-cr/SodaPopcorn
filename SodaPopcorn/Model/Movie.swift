//
//  Movie.swift
//  StarWarsWorld
//
//  Created by Zimplifica Macbook Pro on 3/9/21.
//

import Foundation

struct Movie: Identifiable {
	let id: Int
	let posterPath: String
	let backdrop: String
	let title: String
	let releaseDate: String
	let rating: Double
	let overview: String
	let popularity: Double
	let voteCount: Int
}

extension Movie: Decodable {
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

	init(from decoder: Decoder) throws {
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
}
