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

    public init(apiResponse: GenresApiResponse) {
        self.init(genres: apiResponse.genres?.map({ Genre(apiResponse: $0) }) ?? [])
    }
}

extension Genres: Equatable {
    public static func == (lhs: Genres, rhs: Genres) -> Bool {
        return lhs.genres == rhs.genres
    }
}
