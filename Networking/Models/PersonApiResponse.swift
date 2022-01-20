//
//  PersonApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

import Foundation

public struct PersonApiResponse: Codable {
    public let adult: Bool?
    public let id, gender: Int?
    public let popularity: Double?
    public let alsoKnownAs: [String]?
    public let biography, birthday, deathday, homepage, imdbID, knownForDepartment, name, placeOfBirth, profilePath: String?

    enum CodingKeys: String, CodingKey {
        case adult, biography, birthday, deathday, gender, homepage, id, popularity, name
        case imdbID             = "imdb_id"
        case knownForDepartment = "known_for_department"
        case placeOfBirth       = "place_of_birth"
        case alsoKnownAs        = "also_known_as"
        case profilePath        = "profile_path"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        adult = try container.decodeIfPresent(Bool.self, forKey: .adult)
        alsoKnownAs = try container.decodeIfPresent([String].self, forKey: .alsoKnownAs)
        biography = try container.decodeIfPresent(String.self, forKey: .biography)
        birthday = try container.decodeIfPresent(String.self, forKey: .birthday)
        deathday =  try container.decodeIfPresent(String.self, forKey: .deathday)
        gender = try container.decodeIfPresent(Int.self, forKey: .gender)
        homepage = try container.decodeIfPresent(String.self, forKey: .homepage)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        imdbID = try container.decodeIfPresent(String.self, forKey: .imdbID)
        knownForDepartment = try container.decodeIfPresent(String.self, forKey: .knownForDepartment)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        placeOfBirth = try container.decodeIfPresent(String.self, forKey: .placeOfBirth)
        popularity = try container.decodeIfPresent(Double.self, forKey: .popularity)
        profilePath = try container.decodeIfPresent(String.self, forKey: .profilePath)
    }
}
