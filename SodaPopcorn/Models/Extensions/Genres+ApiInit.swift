//
//  Genres+ApiInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension Genres {
    public init(apiResponse: GenresApiResponse) {
        self.init(genres: apiResponse.genres?.map({ Genre(apiResponse: $0) }) ?? [])
    }
}
