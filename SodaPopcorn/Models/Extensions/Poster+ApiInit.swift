//
//  Poster+ApiInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension Poster {
    public init(apiResponse: PosterApiResponse) {
        self.init(filePath: apiResponse.filePath)
    }
}
