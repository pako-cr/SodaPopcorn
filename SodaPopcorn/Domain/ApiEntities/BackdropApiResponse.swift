//
//  BackdropApiResponse.swift
//  Networking
//
//  Created by Francisco Cordoba on 6/11/21.
//

import Foundation

public struct BackdropApiResponse: Codable {
    let filePath: String?

    private enum CodingKeys: String, CodingKey {
        case filePath = "file_path"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        filePath = try container.decodeIfPresent(String.self, forKey: .filePath)
    }
}
