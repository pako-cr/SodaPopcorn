//
//  Credits.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 10/11/21.
//

import Foundation

public struct Credits {
    public let id: Int?
    public let cast, crew: [Cast]?

    public init(id: Int? = nil, cast: [Cast]? = nil, crew: [Cast]? = nil) {
        self.id = id
        self.cast = cast
        self.crew = crew
    }
}
