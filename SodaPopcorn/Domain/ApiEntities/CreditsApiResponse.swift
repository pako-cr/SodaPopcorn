//
//  CreditsApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 10/11/21.
//

import Foundation

enum Department: String, Codable {
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
struct CreditsApiResponse: Codable {
    let id: Int
    let cast, crew: [CastApiResponse]
}

// MARK: - Cast
struct CastApiResponse: Codable {
    let adult: Bool
    let gender, id: Int
    let knownForDepartment: Department
    let name, originalName, creditID: String
    let popularity: Double
    let profilePath, character, job: String?
    let castID, order: Int?
    let department: Department?

    enum CodingKeys: String, CodingKey {
        case adult, gender, id, name, character, order, department, job, popularity
        case knownForDepartment = "known_for_department"
        case originalName       = "original_name"
        case profilePath        = "profile_path"
        case castID             = "cast_id"
        case creditID           = "credit_id"
    }
}
