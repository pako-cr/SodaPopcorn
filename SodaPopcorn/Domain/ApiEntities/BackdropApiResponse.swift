//
//  BackdropApiResponse.swift
//  Networking
//
//  Created by Francisco Cordoba on 6/11/21.
//

import Foundation

public final class BackdropApiResponse: Codable {
    public let filePath: String?

    private enum BackdropApiResponseCodingKeys: String, CodingKey {
        case filePath = "file_path"
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: BackdropApiResponseCodingKeys.self)
        filePath = try container.decodeIfPresent(String.self, forKey: .filePath)
    }
}
