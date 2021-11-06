//
//  Genre.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/11/21.
//

import Foundation

public final class Genre: Codable {
    public var id: Int?
    public var name: String?

    private enum GenreCodingKeys: String, CodingKey {
        case id
        case name
    }

    required public init(from decoder: Decoder) throws {
        let genreContainer = try decoder.container(keyedBy: GenreCodingKeys.self)

        id = try genreContainer.decodeIfPresent(Int.self, forKey: .id)
        name = try genreContainer.decodeIfPresent(String.self, forKey: .name)
    }
}
