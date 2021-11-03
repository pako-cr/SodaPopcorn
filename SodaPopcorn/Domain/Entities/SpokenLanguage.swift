//
//  SpokenLanguage.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/11/21.
//

import Foundation

public final class SpokenLanguage: Codable {
    public var englishName: String?
    public var isoCode: String?
    public var name: String?

    private enum SpokenLanguageCodingKeys: String, CodingKey {
        case englishName    = "english_name"
        case isoCode        = "iso_639_1"
        case name
    }

    required public init(from decoder: Decoder) throws {
        let spokenLanguageContainer = try decoder.container(keyedBy: SpokenLanguageCodingKeys.self)

        englishName = try spokenLanguageContainer.decode(String.self, forKey: .englishName)
        isoCode = try spokenLanguageContainer.decodeIfPresent(String.self, forKey: .isoCode)
        name = try spokenLanguageContainer.decodeIfPresent(String.self, forKey: .name)
    }
}
