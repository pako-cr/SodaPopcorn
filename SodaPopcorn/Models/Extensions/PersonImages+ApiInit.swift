//
//  PersonImages+ApiInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension PersonImages {
    public init(apiResponse: PersonImagesApiResponse) {
        self.init(id: apiResponse.id,
                  images: apiResponse.profiles?.map({ PersonImage(apiResponse: $0) }) )
    }
}
