//
//  GenreApiResponse.swift
//  Networking
//
//  Created by Francisco Cordoba on 6/11/21.
//

import Foundation

public final class GenreApiResponse: Codable {
    public var id: Int?
    public var name: String?

    private enum GenreCodingKeys: String, CodingKey {
        case id
        case name
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: GenreCodingKeys.self)

        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }
}
