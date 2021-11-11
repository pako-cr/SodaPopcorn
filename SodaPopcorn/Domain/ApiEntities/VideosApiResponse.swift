//
//  VideosApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

public final class VideosApiResponse: Decodable {
    public let id: String?
    public let results: [VideoApiResponse]?

    private enum CondingKeys: CodingKey {
        case id
        case results
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CondingKeys.self)

        id = try String(container.decode(Int.self, forKey: .id))
        results = try container.decodeIfPresent([VideoApiResponse].self, forKey: .results)
    }
}
