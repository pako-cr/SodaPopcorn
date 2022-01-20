//
//  Backdrop+ConvenienceInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension Backdrop {
    public init(apiResponse: BackdropApiResponse) {
        self.init(filePath: apiResponse.filePath)
    }
}
