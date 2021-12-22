//
//  ImagesApiResponse.swift
//  Networking
//
//  Created by Francisco Cordoba on 6/11/21.
//

public struct ImagesApiResponse: Decodable {
    public let id: String?
    public let backdropsApiResponse: [BackdropApiResponse]?
    public let postersApiResponse: [PosterApiResponse]?

    private enum CodingKeys: String, CodingKey {
        case id, backdrops, posters
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try String(container.decode(Int.self, forKey: .id))
        backdropsApiResponse = try container.decodeIfPresent([BackdropApiResponse].self, forKey: .backdrops)
        postersApiResponse = try container.decodeIfPresent([PosterApiResponse].self, forKey: .posters)
    }
}
