//
//  PersonImages.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

public struct PersonImages: Hashable {
    public let id: Int?
    public let images: [PersonImage]?

    public init(id: Int? = nil, images: [PersonImage]? = nil) {
        self.id = id
        self.images = images
    }
}
