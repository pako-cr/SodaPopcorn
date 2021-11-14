//
//  PersonImage.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

public struct PersonImage: Hashable {
    let filePath: String?
    let voteCount, width, height: Int?
    let aspectRatio, voteAverage: Double?

    init(filePath: String? = nil, voteCount: Int? = nil, width: Int? = nil, height: Int? = nil, aspectRatio: Double? = nil, voteAverage: Double? = nil) {
        self.filePath = filePath
        self.voteCount = voteCount
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.voteAverage = voteAverage
    }

    public init(apiResponse: PersonImageApiResponse) {
        self.init(filePath: apiResponse.filePath, voteCount: apiResponse.voteCount, width: apiResponse.width, height: apiResponse.height, aspectRatio: apiResponse.aspectRatio, voteAverage: apiResponse.voteAverage)
    }
}
