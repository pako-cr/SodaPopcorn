//
//  ProductionCountry.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/11/21.
//

import Foundation

public final class ProductionCountry: Codable {
    public var isoCode: String?
    public var name: String?

    private enum ProductionCountryCodingKeys: String, CodingKey {
        case isoCode = "iso_3166_1"
        case name
    }

    required public init(from decoder: Decoder) throws {
        let productionCountryContainer = try decoder.container(keyedBy: ProductionCountryCodingKeys.self)

        isoCode = try productionCountryContainer.decode(String.self, forKey: .isoCode)
        name = try productionCountryContainer.decodeIfPresent(String.self, forKey: .name)
    }
}
