//
//  ProductionCompanyApiResponse.swift
//  Networking
//
//  Created by Francisco Cordoba on 6/11/21.
//

import Foundation

public struct ProductionCompanyApiResponse: Codable {
    public let id: Int?
    public let logoPath, name, originCountry: String?

    private enum CodingKeys: String, CodingKey {
        case id, name
        case logoPath       = "logo_path"
        case originCountry  = "origin_country"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        logoPath = try container.decodeIfPresent(String.self, forKey: .logoPath)
        originCountry = try container.decodeIfPresent(String.self, forKey: .originCountry)
    }
}
