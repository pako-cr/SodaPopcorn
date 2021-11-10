//
//  ImagesApiResponse.swift
//  Networking
//
//  Created by Francisco Cordoba on 6/11/21.
//

import Foundation

public final class ImagesApiResponse: Codable {
    public var id: String?
    public var backdropsApiResponse: [BackdropApiResponse]?
    public var postersApiResponse: [PosterApiResponse]?

    private enum ImagesApiResponseCodingKeys: String, CodingKey {
        case id
        case backdrops
        case posters
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ImagesApiResponseCodingKeys.self)

        id = try String(container.decode(Int.self, forKey: .id))
        backdropsApiResponse = try container.decodeIfPresent([BackdropApiResponse].self, forKey: .backdrops)
        postersApiResponse = try container.decodeIfPresent([PosterApiResponse].self, forKey: .posters)
    }
}
