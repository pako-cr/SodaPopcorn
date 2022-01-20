//
//  SocialNetworksApiResponse.swift
//  Networking
//
//  Created by Francisco Cordoba on 6/11/21.
//

import Foundation

public struct SocialNetworksApiResponse: Codable {
    public let id, facebookId, instagramId, twitterId: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case facebookId     = "facebook_id"
        case instagramId    = "instagram_id"
        case twitterId      = "twitter_id"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try String(container.decode(Int.self, forKey: .id))
        facebookId = try container.decodeIfPresent(String.self, forKey: .facebookId)
        instagramId = try container.decodeIfPresent(String.self, forKey: .instagramId)
        twitterId = try container.decodeIfPresent(String.self, forKey: .twitterId)
    }
}
