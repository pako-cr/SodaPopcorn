//
//  Cast+ConvenienceInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension Cast {
    public init(apiResponse: CastApiResponse) {
        self.init(adult: apiResponse.adult, gender: apiResponse.gender, id: apiResponse.id, knownForDepartment: apiResponse.knownForDepartment, name: apiResponse.name, originalName: apiResponse.originalName, popularity: apiResponse.popularity, profilePath: apiResponse.profilePath, castID: apiResponse.castID, character: apiResponse.character, creditID: apiResponse.creditID, order: apiResponse.order, department: apiResponse.department, job: apiResponse.job)
    }
}
