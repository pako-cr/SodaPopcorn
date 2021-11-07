//
//  MovieImages.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

public final class MovieImages: Hashable {
    public var id: String?
    public var backdrops: [Backdrop]?
    public var logos: [Logo]?
    public var posters: [Poster]?

    private init(id: String? = nil, backdrops: [Backdrop]? = nil, logos: [Logo]? = nil, posters: [Poster]? = nil) {
        self.id = id
        self.backdrops = backdrops
        self.logos = logos
        self.posters = posters
    }

    convenience init(apiResponse: ImagesApiResponse) {
        self.init(id: apiResponse.id,
                  backdrops: apiResponse.backdropsApiResponse?.map({ Backdrop(apiResponse: $0) }) ?? [] ,
                  logos: apiResponse.logosApiResponse?.map({ Logo(apiResponse: $0) }) ?? [],
                  posters: apiResponse.postersApiResponse?.map({ Poster(apiResponse: $0) }) ?? [])
    }

    convenience init() {
        self.init(id: nil, backdrops: nil, logos: nil, posters: nil)
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: MovieImages, rhs: MovieImages) -> Bool {
        return lhs.id == rhs.id
    }
}
