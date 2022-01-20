//
//  PersonInMovieApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

public struct PersonInMovieApiResponse: Decodable {
    public let cast, crew: [MovieApiResponse]?
    public let id: Int?

    enum CodingKeys: String, CodingKey {
        case id, cast, crew
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(Int.self, forKey: .id)
        cast = try container.decodeIfPresent([MovieApiResponse].self, forKey: .cast)
        crew = try container.decodeIfPresent([MovieApiResponse].self, forKey: .crew)
    }
}
