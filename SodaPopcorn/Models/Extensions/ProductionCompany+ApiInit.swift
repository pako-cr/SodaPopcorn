//
//  ProductionCompany+ApiInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension ProductionCompany {
    public init(apiResponse: ProductionCompanyApiResponse) {
        self.init(id: apiResponse.id,
                  logoPath: apiResponse.logoPath,
                  name: apiResponse.name)
    }
}
