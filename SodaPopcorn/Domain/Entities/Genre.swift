//
//  Genre.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/11/21.
//

struct Genre {
    public var id: Int?
    public var name: String?

    init(id: Int?, name: String?) {
        self.id = id
        self.name = name
    }

    init(apiResponse: GenreApiResponse) {
        self.init(id: apiResponse.id, name: apiResponse.name)
    }
}

extension Genre: Equatable {
    public static func == (lhs: Genre, rhs: Genre) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
