//
//  Poster.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

public struct Poster: Hashable {
    public let filePath: String?

    public init(filePath: String? = nil) {
        self.filePath = filePath
    }

    public init(apiResponse: PosterApiResponse) {
        self.init(filePath: apiResponse.filePath)
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
