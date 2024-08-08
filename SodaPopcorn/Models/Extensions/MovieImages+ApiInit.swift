//
//  MovieImages.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension MovieImages {
    public init(apiResponse: ImagesApiResponse) {
        self.init(id: apiResponse.id,
                  backdrops: apiResponse.backdropsApiResponse?.map({ Backdrop(apiResponse: $0) }) ?? [],
                  posters: apiResponse.postersApiResponse?.map({ Poster(apiResponse: $0) }) ?? [])
    }
}
