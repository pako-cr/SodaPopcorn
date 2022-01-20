//
//  PersonInMovie.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

public struct PersonInMovie: Hashable {
    public let cast, crew: [Movie]?
    public let id: Int?

    public init(cast: [Movie]? = nil, crew: [Movie]? = nil, id: Int? = nil) {
        self.cast = cast
        self.crew = crew
        self.id = id
    }
}
