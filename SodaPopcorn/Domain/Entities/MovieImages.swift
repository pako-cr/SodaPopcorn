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

    convenience init(imagesApiResponse: ImagesApiResponse) {
        self.init(id: imagesApiResponse.id,
                  backdrops: imagesApiResponse.backdropsApiResponse?.map({ Backdrop(backdropApiResponse: $0) }) ?? [] ,
                  logos: imagesApiResponse.logosApiResponse?.map({ Logo(logoApiResponse: $0) }) ?? [],
                  posters: imagesApiResponse.postersApiResponse?.map({ Poster(posterApiResponse: $0) }) ?? [])
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
