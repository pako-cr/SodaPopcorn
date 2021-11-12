//
//  PersonImageApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

public struct PersonImageApiResponse: Decodable {
    let filePath: String?
    let voteCount, width, height: Int?
    let aspectRatio, voteAverage: Double?

    enum CodingKeys: String, CodingKey {
        case height, width
        case aspectRatio    = "aspect_ratio"
        case filePath       = "file_path"
        case voteAverage    = "vote_average"
        case voteCount      = "vote_count"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        height = try container.decodeIfPresent(Int.self, forKey: .height)
        width = try container.decodeIfPresent(Int.self, forKey: .width)
        aspectRatio = try container.decodeIfPresent(Double.self, forKey: .aspectRatio)
        filePath = try container.decodeIfPresent(String.self, forKey: .filePath)
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage)
        voteCount = try container.decodeIfPresent(Int.self, forKey: .voteCount)
    }
}
