//
//  GenreApiResponse.swift
//  Networking
//
//  Created by Francisco Cordoba on 6/11/21.
//

public struct GenreApiResponse: Codable {
    let id: Int?
    let name: String?

    private enum CodingKeys: String, CodingKey {
        case id, name
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }
}
