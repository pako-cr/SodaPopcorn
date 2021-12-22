//
//  CreditsApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 10/11/21.
//

import Foundation

public enum Department: String, Codable {
    case acting         = "Acting"
    case art            = "Art"
    case camera         = "Camera"
    case costumeMakeUp  = "Costume & Make-Up"
    case crew           = "Crew"
    case directing      = "Directing"
    case editing        = "Editing"
    case lighting       = "Lighting"
    case production     = "Production"
    case sound          = "Sound"
    case visualEffects  = "Visual Effects"
    case writing        = "Writing"
}

// MARK: - Credits
public struct CreditsApiResponse: Codable {
    public let id: Int
    public let cast, crew: [CastApiResponse]
}

// MARK: - Cast
public struct CastApiResponse: Codable {
    public let adult: Bool
    public let gender, id: Int
    public let knownForDepartment: Department
    public let name, originalName, creditID: String
    public let popularity: Double
    public let profilePath, character, job: String?
    public let castID, order: Int?
    public let department: Department?

    enum CodingKeys: String, CodingKey {
        case adult, gender, id, name, character, order, department, job, popularity
        case knownForDepartment = "known_for_department"
        case originalName       = "original_name"
        case profilePath        = "profile_path"
        case castID             = "cast_id"
        case creditID           = "credit_id"
    }
}
