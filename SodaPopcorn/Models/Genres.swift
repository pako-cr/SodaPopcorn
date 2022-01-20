//
//  Genres.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 16/11/21.
//

public struct Genres: Hashable {
    public var genres: [Genre]?

    public init(genres: [Genre]? = nil) {
        self.genres = genres
    }
}

extension Genres: Equatable {
    public static func == (lhs: Genres, rhs: Genres) -> Bool {
        return lhs.genres == rhs.genres
    }
}
