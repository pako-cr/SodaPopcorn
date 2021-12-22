//
//  Person.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

public struct Person: Hashable {
    public let adult: Bool?
    public let alsoKnownAs: [String]?
    public let biography, birthday, deathday, homepage, imdbID, knownForDepartment, name, placeOfBirth, profilePath: String?
    public let id, gender: Int?
    public let popularity: Double?

    public init(adult: Bool? = nil, alsoKnownAs: [String]? = nil, biography: String? = nil, birthday: String? = nil, deathday: String? = nil, homepage: String? = nil, imdbID: String? = nil, knownForDepartment: String? = nil, name: String? = nil, placeOfBirth: String? = nil, profilePath: String? = nil, id: Int? = nil, gender: Int? = nil, popularity: Double? = nil) {
        self.adult = adult
        self.alsoKnownAs = alsoKnownAs
        self.biography = biography
        self.birthday = birthday
        self.deathday = deathday
        self.homepage = homepage
        self.imdbID = imdbID
        self.knownForDepartment = knownForDepartment
        self.name = name
        self.placeOfBirth = placeOfBirth
        self.profilePath = profilePath
        self.id = id
        self.gender = gender
        self.popularity = popularity
    }

    public init(apiResponse: PersonApiResponse) {
        self.init(adult: apiResponse.adult, alsoKnownAs: apiResponse.alsoKnownAs, biography: apiResponse.biography, birthday: apiResponse.birthday, deathday: apiResponse.deathday, homepage: apiResponse.homepage, imdbID: apiResponse.imdbID, knownForDepartment: apiResponse.knownForDepartment, name: apiResponse.name, placeOfBirth: apiResponse.placeOfBirth, profilePath: apiResponse.profilePath, id: apiResponse.id, gender: apiResponse.gender, popularity: apiResponse.popularity)
    }
}
