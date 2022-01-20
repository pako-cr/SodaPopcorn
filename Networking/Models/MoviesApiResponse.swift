//
//  MoviesApiResponse.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 6/11/21.
//

public struct MoviesApiResponse: Decodable {
    public let page: Int?
    public let numberOfResults: Int?
    public let numberOfPages: Int?
    public let movies: [MovieApiResponse]?

    private enum CodingKeys: String, CodingKey {
        case page
        case numberOfResults    = "total_results"
        case numberOfPages      = "total_pages"
        case movies             = "results"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        page = try container.decode(Int.self, forKey: .page)
        numberOfResults = try container.decode(Int.self, forKey: .numberOfResults)
        numberOfPages = try container.decode(Int.self, forKey: .numberOfPages)
        movies = try container.decode([MovieApiResponse].self, forKey: .movies)
    }
}
