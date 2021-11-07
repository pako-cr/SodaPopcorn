//
//  Poster.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

public final class Poster: Hashable {
    public var filePath: String?

    private init(filePath: String? = nil) {
        self.filePath = filePath
    }

    convenience init(posterApiResponse: PosterApiResponse) {
        self.init(filePath: posterApiResponse.filePath)
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(filePath)
    }
}

extension Poster: Equatable {
    public static func == (lhs: Poster, rhs: Poster) -> Bool {
        return lhs.filePath == rhs.filePath
    }
}
