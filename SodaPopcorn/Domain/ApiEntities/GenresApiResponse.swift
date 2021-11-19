//
//  GenresApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 16/11/21.
//

public struct GenresApiResponse: Codable {
    let genres: [GenreApiResponse]?

    private enum CodingKeys: String, CodingKey {
        case genres
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        genres = try container.decodeIfPresent([GenreApiResponse].self, forKey: .genres)
    }
}
