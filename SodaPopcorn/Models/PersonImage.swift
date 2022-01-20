//
//  PersonImage.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

public struct PersonImage: Hashable {
    public let filePath: String?
    public let voteCount, width, height: Int?
    public let aspectRatio, voteAverage: Double?

    public init(filePath: String? = nil, voteCount: Int? = nil, width: Int? = nil, height: Int? = nil, aspectRatio: Double? = nil, voteAverage: Double? = nil) {
        self.filePath = filePath
        self.voteCount = voteCount
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.voteAverage = voteAverage
    }
}
