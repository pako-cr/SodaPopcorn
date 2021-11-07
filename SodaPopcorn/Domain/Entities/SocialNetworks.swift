//
//  SocialNetworks.swift
//  SodaPopcorn
//
//  Created by Francisco Zimplifica on 6/11/21.
//

public final class SocialNetworks: Hashable {
    public var id: String?
    public var facebookId: String?
    public var instagramId: String?
    public var twitterId: String?

    private init(id: String? = nil, facebookId: String? = nil, instagramId: String? = nil, twitterId: String? = nil) {
        self.id = id
        self.facebookId = facebookId
        self.instagramId = instagramId
        self.twitterId = twitterId
    }

    convenience init(apiResponse: SocialNetworksApiResponse) {
        self.init(id: apiResponse.id,
                  facebookId: apiResponse.facebookId,
                  instagramId: apiResponse.instagramId,
                  twitterId: apiResponse.twitterId)
    }

    convenience init() {
        self.init(id: nil, facebookId: nil, instagramId: nil, twitterId: nil)
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: SocialNetworks, rhs: SocialNetworks) -> Bool {
        return lhs.id == rhs.id
    }
}
