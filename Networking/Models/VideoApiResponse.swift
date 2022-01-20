//
//  VideoApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

public struct VideoApiResponse: Decodable {
    public let id, name, key, site, type: String?

    private enum CodingKeys: CodingKey {
        case id, name, key, site, type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        site = try container.decodeIfPresent(String.self, forKey: .site)
        type = try container.decodeIfPresent(String.self, forKey: .type)
    }
}
