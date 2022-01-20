//
//  Gallery.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 9/11/21.
//

public struct Gallery {
    public let videos: [Video]?
    public let backdrops: [Backdrop]?
    public let posters: [Poster]?

    public init(videos: [Video]?, backdrops: [Backdrop]?, posters: [Poster]?) {
        self.videos = videos
        self.backdrops = backdrops
        self.posters = posters
    }
}
