//
//  SocialNetworksApiResponse.swift
//  Networking
//
//  Created by Francisco Cordoba on 6/11/21.
//

import Foundation

public final class SocialNetworksApiResponse: Codable {
    public var id: String?
    public var facebookId: String?
    public var instagramId: String?
    public var twitterId: String?

    private enum SocialNetworksApiResponseCodingKeys: String, CodingKey {
        case id
        case facebookId     = "facebook_id"
        case instagramId    = "instagram_id"
        case twitterId      = "twitter_id"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: SocialNetworksApiResponseCodingKeys.self)

        id = try String(container.decode(Int.self, forKey: .id))
        facebookId = try container.decodeIfPresent(String.self, forKey: .facebookId)
        instagramId = try container.decodeIfPresent(String.self, forKey: .instagramId)
        twitterId = try container.decodeIfPresent(String.self, forKey: .twitterId)
    }
}
