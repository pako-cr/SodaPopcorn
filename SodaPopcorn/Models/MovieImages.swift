//
//  MovieImages.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

public struct MovieImages: Hashable {
    public let id: String?
    public let backdrops: [Backdrop]?
    public let posters: [Poster]?

    public init(id: String? = nil, backdrops: [Backdrop]? = nil, posters: [Poster]? = nil) {
        self.id = id
        self.backdrops = backdrops
        self.posters = posters
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: MovieImages, rhs: MovieImages) -> Bool {
        return lhs.id == rhs.id
    }
}
