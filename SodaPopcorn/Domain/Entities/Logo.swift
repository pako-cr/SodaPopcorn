//
//  Logo.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

import Foundation

public final class Logo: Codable, Hashable {
    public var filePath: String?

    private enum LogoCodingKeys: String, CodingKey {
        case filePath = "file_path"
    }

    required public init(from decoder: Decoder) throws {
        let logoContainer = try decoder.container(keyedBy: LogoCodingKeys.self)

        filePath = try logoContainer.decodeIfPresent(String.self, forKey: .filePath)
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(filePath)
    }

    public static func == (lhs: Logo, rhs: Logo) -> Bool {
        return lhs.filePath == rhs.filePath
    }
}
