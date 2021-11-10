//
//  Genre.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/11/21.
//

public final class Genre {
    public var id: Int?
    public var name: String?

    private init(id: Int?, name: String?) {
        self.id = id
        self.name = name
    }

    convenience init(apiResponse: GenreApiResponse) {
        self.init(id: apiResponse.id, name: apiResponse.name)
    }
}

extension Genre: Equatable {
    public static func == (lhs: Genre, rhs: Genre) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
