//
//  Credits+ConvenienceInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension Credits {
    public init(apiResponse: CreditsApiResponse) {
        self.init(id: apiResponse.id,
                  cast: apiResponse.cast.compactMap({ return !$0.adult ? Cast(apiResponse: $0) : nil }), // Remove adult cast
                  crew: apiResponse.crew.compactMap({ return !$0.adult ? Cast(apiResponse: $0) : nil })) // Remove adult crew
    }
}
