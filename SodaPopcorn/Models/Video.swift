//
//  Video.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

public struct Video: Hashable {
    public let id: String?
    public let name: String?
    public let key: String?
    public let site: String?
    public let type: String?

    public init(id: String?, name: String?, key: String?, site: String?, type: String?) {
        self.id = id
        self.name = name
        self.key = key
        self.site = site
        self.type = type
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.id == rhs.id
    }
}
