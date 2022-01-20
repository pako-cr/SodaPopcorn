//
//  PersonImage.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension PersonImage {
    public init(apiResponse: PersonImageApiResponse) {
        self.init(filePath: apiResponse.filePath, voteCount: apiResponse.voteCount, width: apiResponse.width, height: apiResponse.height, aspectRatio: apiResponse.aspectRatio, voteAverage: apiResponse.voteAverage)
    }
}
