//
//  Genre.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/11/21.
//

public struct Genre: Hashable {
    public var id: Int?
    public var name: String?

    public init(id: Int?, name: String?) {
        self.id = id
        self.name = name
    }

    public init(apiResponse: GenreApiResponse) {
        self.init(id: apiResponse.id, name: apiResponse.name)
    }
}

extension Genre: Equatable {
    public static func == (lhs: Genre, rhs: Genre) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
