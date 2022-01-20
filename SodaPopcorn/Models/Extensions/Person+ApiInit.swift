//
//  Person+ApiInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 14/1/22.
//

import Networking

extension Person {
    public init(apiResponse: PersonApiResponse) {
        self.init(adult: apiResponse.adult, alsoKnownAs: apiResponse.alsoKnownAs, biography: apiResponse.biography, birthday: apiResponse.birthday, deathday: apiResponse.deathday, homepage: apiResponse.homepage, imdbID: apiResponse.imdbID, knownForDepartment: apiResponse.knownForDepartment, name: apiResponse.name, placeOfBirth: apiResponse.placeOfBirth, profilePath: apiResponse.profilePath, id: apiResponse.id, gender: apiResponse.gender, popularity: apiResponse.popularity)
    }
}
