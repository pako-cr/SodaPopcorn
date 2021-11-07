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

    convenience init(genreApiResponse: GenreApiResponse) {
        self.init(id: genreApiResponse.id, name: genreApiResponse.name)
    }
}

extension Genre: Equatable {
    public static func == (lhs: Genre, rhs: Genre) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
