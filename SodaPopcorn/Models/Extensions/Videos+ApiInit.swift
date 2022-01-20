//
//  Videos+ApiInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension Videos {
    public init(apiResponse: VideosApiResponse) {
        self.init(id: apiResponse.id,
                  results: apiResponse.results?.map({ Video(apiResponse: $0) }) ?? [])
    }
}
