//
//  SocialNetworks+ApiInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension SocialNetworks {
    public init(apiResponse: SocialNetworksApiResponse) {
        var networks: [SocialNetwork] = []

        if let instagramId = apiResponse.instagramId, !instagramId.isEmpty {
            networks.append(.instagram(userId: instagramId))
        }

        if let facebookId = apiResponse.facebookId, !facebookId.isEmpty {
            networks.append(.facebook(userId: facebookId))
        }

        if let twitterId = apiResponse.twitterId, !twitterId.isEmpty {
            networks.append(.twitter(userId: twitterId))
        }

        self.init(id: apiResponse.id, networks: networks)
    }
}
