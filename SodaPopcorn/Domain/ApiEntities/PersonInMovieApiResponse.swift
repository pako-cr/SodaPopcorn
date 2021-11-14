//
//  PersonInMovieApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

struct PersonInMovieApiResponse: Decodable {
    let cast, crew: [MovieApiResponse]?
    let id: Int?

    enum CodingKeys: String, CodingKey {
        case id, cast, crew
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(Int.self, forKey: .id)
        cast = try container.decodeIfPresent([MovieApiResponse].self, forKey: .cast)
        crew = try container.decodeIfPresent([MovieApiResponse].self, forKey: .crew)
    }
}
