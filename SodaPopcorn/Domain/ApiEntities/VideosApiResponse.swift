//
//  VideosApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

public struct VideosApiResponse: Decodable {
    let id: String?
    let results: [VideoApiResponse]?

    private enum CondingKeys: CodingKey {
        case id, results
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CondingKeys.self)

        id = try String(container.decode(Int.self, forKey: .id))
        results = try container.decodeIfPresent([VideoApiResponse].self, forKey: .results)
    }
}
