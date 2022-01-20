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

public struct SocialNetworks: Hashable {
    public var id: String?
    public var networks: [SocialNetwork]?

    public init(id: String? = nil, networks: [SocialNetwork]? = nil) {
        self.id = id
        self.networks = networks
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: SocialNetworks, rhs: SocialNetworks) -> Bool {
        return lhs.id == rhs.id
    }
}
