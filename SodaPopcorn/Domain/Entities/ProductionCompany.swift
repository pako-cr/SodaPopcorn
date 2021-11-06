//
//  ProductionCompany.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/11/21.
//

import Foundation

public final class ProductionCompany: Codable {
    public var id: Int?
    public var logoPath: String?
    public var name: String?
    public var originCountry: String?

    private enum ProductionCompanyCodingKeys: String, CodingKey {
        case id
        case logoPath       = "logo_path"
        case name
        case originCountry  = "origin_country"
    }

    public init(from decoder: Decoder) throws {
        let productionCompanyContainer = try decoder.container(keyedBy: ProductionCompanyCodingKeys.self)

        id = try productionCompanyContainer.decodeIfPresent(Int.self, forKey: .id)
        logoPath = try productionCompanyContainer.decodeIfPresent(String.self, forKey: .logoPath)
        name = try productionCompanyContainer.decodeIfPresent(String.self, forKey: .name)
        originCountry = try productionCompanyContainer.decodeIfPresent(String.self, forKey: .originCountry)
    }
}
