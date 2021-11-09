//
//  SocialNetworks.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 6/11/21.
//

public enum SocialNetwork: Hashable {
    case instagram(userId: String)
    case facebook(userId: String)
    case twitter(userId: String)
}

public final class SocialNetworks: Hashable {
    public var id: String?
    public var networks: [SocialNetwork]?

    private init(id: String? = nil, networks: [SocialNetwork]?) {
        self.id = id
        self.networks = networks
    }

    convenience init(apiResponse: SocialNetworksApiResponse) {
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

    convenience init() {
        self.init(id: nil, networks: nil)
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: SocialNetworks, rhs: SocialNetworks) -> Bool {
        return lhs.id == rhs.id
    }
}
