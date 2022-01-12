//
//  CreditsApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 10/11/21.
//

import Foundation

// MARK: - Credits
public struct CreditsApiResponse: Codable {
    public let id: Int
    public let cast, crew: [CastApiResponse]
}

// MARK: - Cast
public struct CastApiResponse: Codable {
    public let adult: Bool
    public let gender, id: Int
    public let name, originalName, creditID: String
    public let popularity: Double
    public let profilePath, character, job, knownForDepartment, department: String?
    public let castID, order: Int?

    enum CodingKeys: String, CodingKey {
        case adult, gender, id, name, character, order, department, job, popularity
        case knownForDepartment = "known_for_department"
        case originalName       = "original_name"
        case profilePath        = "profile_path"
        case castID             = "cast_id"
        case creditID           = "credit_id"
    }
}
