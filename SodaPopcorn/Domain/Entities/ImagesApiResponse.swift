//
//  ImagesApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

import Foundation

public final class ImagesApiResponse: Codable, Hashable {
    public var id: String?
    public var backdrops: [Backdrop]?
    public var logos: [Logo]?
    public var posters: [Poster]?

    private enum ImagesApiResponseCodingKeys: String, CodingKey {
        case id
        case backdrops
        case logos
        case posters
    }

    public init(from decoder: Decoder) throws {
        let imageContainer = try decoder.container(keyedBy: ImagesApiResponseCodingKeys.self)

        id = try String(imageContainer.decode(Int.self, forKey: .id))
        backdrops = try imageContainer.decodeIfPresent([Backdrop].self, forKey: .backdrops)
        logos = try imageContainer.decodeIfPresent([Logo].self, forKey: .logos)
        posters = try imageContainer.decodeIfPresent([Poster].self, forKey: .posters)
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: ImagesApiResponse, rhs: ImagesApiResponse) -> Bool {
        return lhs.id == rhs.id
    }
}
