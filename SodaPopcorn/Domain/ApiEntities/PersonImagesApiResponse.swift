//
//  PersonImagesApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

public struct PersonImagesApiResponse: Decodable {
    let id: Int?
    let profiles: [PersonImageApiResponse]?

    enum CodingKeys: String, CodingKey {
        case id, profiles
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(Int.self, forKey: .id)
        profiles = try container.decodeIfPresent([PersonImageApiResponse].self, forKey: .profiles)
    }
}
