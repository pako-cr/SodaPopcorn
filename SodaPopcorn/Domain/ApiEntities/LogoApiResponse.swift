//
//  LogoApiResponse.swift
//  Networking
//
//  Created by Francisco Cordoba on 6/11/21.
//

import Foundation

public final class LogoApiResponse: Codable {
    public var filePath: String?

    private enum LogoApiResponseCodingKeys: String, CodingKey {
        case filePath = "file_path"
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LogoApiResponseCodingKeys.self)
        filePath = try container.decodeIfPresent(String.self, forKey: .filePath)
    }
}
