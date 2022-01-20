//
//  PersonInMovie+ApiInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension PersonInMovie {
    public init(apiResponse: PersonInMovieApiResponse) {
        self.init(cast: apiResponse.cast?.map({Movie(apiResponse: $0)}),
                  crew: apiResponse.crew?.map({Movie(apiResponse: $0)}),
                  id: apiResponse.id)
    }
}
