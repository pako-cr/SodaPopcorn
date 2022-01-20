//
//  Video+ApiInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension Video {
    public init(apiResponse: VideoApiResponse) {
        self.init(id: apiResponse.id,
                  name: apiResponse.name,
                  key: apiResponse.key,
                  site: apiResponse.site,
                  type: apiResponse.type)
    }
}
