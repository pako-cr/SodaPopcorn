//
//  GenreApiResponse.swift
//  Networking
//
//  Created by Francisco Cordoba on 6/11/21.
//

public struct GenreApiResponse: Codable {
    public let id: Int?
    public let name: String?

    private enum CodingKeys: String, CodingKey {
        case id, name
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }
}

public struct GenreApiRequest: Codable {
    public let id: Int?
    public let name: String?

    public init(id: Int?, name: String?) {
        self.id = id
        self.name = name
    }
}

