//
//  Credits.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 10/11/21.
//

import Foundation

public struct Credits {
    let id: Int?
    let cast, crew: [Cast]?

    init(id: Int? = nil, cast: [Cast]? = nil, crew: [Cast]? = nil) {
        self.id = id
        self.cast = cast
        self.crew = crew
    }

    init(apiResponse: CreditsApiResponse) {
        self.init(id: apiResponse.id,
                  cast: apiResponse.cast.map({ Cast(apiResponse: $0) }),
                  crew: apiResponse.crew.map({ Cast(apiResponse: $0) }))
    }
}
