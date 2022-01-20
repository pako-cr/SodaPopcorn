//
//  Genre+ApiInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension Genre {
    public init(apiResponse: GenreApiResponse) {
        self.init(id: apiResponse.id, name: apiResponse.name)
    }
}
