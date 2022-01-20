//
//  Cast.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

public struct Cast: Hashable {
    public let adult: Bool?
    public let popularity: Double?
    public let gender, id, order, castID: Int?
    public let knownForDepartment, department: String?
    public let name, originalName, profilePath, character, creditID, job: String?

    public init(adult: Bool? = nil, gender: Int? = nil, id: Int? = nil, knownForDepartment: String? = nil, name: String? = nil, originalName: String? = nil, popularity: Double? = nil, profilePath: String? = nil, castID: Int? = nil, character: String? = nil, creditID: String? = nil, order: Int? = nil, department: String? = nil, job: String? = nil) {
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
}
