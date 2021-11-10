//
//  Credits.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 10/11/21.
//

import Foundation

public struct Credits {
    let id: Int?
    let cast, crew: [Cast]?

    init(id: Int? = nil, cast: [Cast]? = nil, crew: [Cast]? = nil) {
        self.id = id
        self.cast = cast
        self.crew = crew
    }

    init(apiResponse: CreditsApiResponse) {
        self.init(id: apiResponse.id,
                  cast: apiResponse.cast.map({ Cast(apiResponse: $0) }),
                  crew: apiResponse.crew.map({ Cast(apiResponse: $0) }))
    }
}

// MARK: - Cast
public struct Cast: Hashable {
    let adult: Bool?
    let gender, id: Int?
    let knownForDepartment: Department?
    let name, originalName: String?
    let popularity: Double?
    let profilePath: String?
    let castID: Int?
    let character: String?
    let creditID: String?
    let order: Int?
    let department: Department?
    let job: String?

    init(adult: Bool? = nil, gender: Int? = nil, id: Int? = nil, knownForDepartment: Department? = nil, name: String? = nil, originalName: String? = nil, popularity: Double? = nil, profilePath: String? = nil, castID: Int? = nil, character: String? = nil, creditID: String? = nil, order: Int? = nil, department: Department? = nil, job: String? = nil) {
        self.adult = adult
        self.gender = gender
        self.id = id
        self.knownForDepartment = knownForDepartment
        self.name = name
        self.originalName = originalName
        self.popularity = popularity
        self.profilePath = profilePath
        self.castID = castID
        self.character = character
        self.creditID = creditID
        self.order = order
        self.department = department
        self.job = job
    }

    init(apiResponse: CastApiResponse) {
        self.init(adult: apiResponse.adult, gender: apiResponse.gender, id: apiResponse.id, knownForDepartment: apiResponse.knownForDepartment, name: apiResponse.name, originalName: apiResponse.originalName, popularity: apiResponse.popularity, profilePath: apiResponse.profilePath, castID: apiResponse.castID, character: apiResponse.character, creditID: apiResponse.creditID, order: apiResponse.order, department: apiResponse.department, job: apiResponse.job)
    }
}
