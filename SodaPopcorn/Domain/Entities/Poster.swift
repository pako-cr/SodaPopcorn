//
//  Poster.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

import Foundation

public final class Poster: Codable, Hashable {
    public var filePath: String?

    private enum PosterCodingKeys: String, CodingKey {
        case filePath = "file_path"
    }

    required public init(from decoder: Decoder) throws {
        let posterContainer = try decoder.container(keyedBy: PosterCodingKeys.self)

        filePath = try posterContainer.decodeIfPresent(String.self, forKey: .filePath)
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(filePath)
    }

    public static func == (lhs: Poster, rhs: Poster) -> Bool {
        return lhs.filePath == rhs.filePath
    }
}
