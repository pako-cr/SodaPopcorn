//
//  Video.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

public struct Video: Hashable {
    let id: String?
    let name: String?
    let key: String?
    let site: String?
    let type: String?

    init(id: String?, name: String?, key: String?, site: String?, type: String?) {
        self.id = id
        self.name = name
        self.key = key
        self.site = site
        self.type = type
    }

    init(apiResponse: VideoApiResponse) {
        self.init(id: apiResponse.id,
                  name: apiResponse.name,
                  key: apiResponse.key,
                  site: apiResponse.site,
                  type: apiResponse.type)
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.id == rhs.id
    }
}
