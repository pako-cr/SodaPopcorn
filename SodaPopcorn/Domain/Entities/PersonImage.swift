//
//  PersonImage.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

struct PersonImage: Hashable {
    let filePath: String?
    let voteCount, width, height: Int?
    let aspectRatio, voteAverage: Double?

    init(filePath: String?, voteCount: Int?, width: Int?, height: Int?, aspectRatio: Double?, voteAverage: Double?) {
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
