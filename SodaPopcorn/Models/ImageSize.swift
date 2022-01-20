//
//  ImageSize.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/1/22.
//

import Foundation

public enum PosterSize: String {
    case w92, w154, w185, w342, w500, w780, original
}

public enum BackdropSize: String {
    case w300, w780, w1280, original
}

public enum LogoSize: String {
    case w45, w92, w154, w185, w300, w500, original
}

public enum ProfileSize: String {
    case w45, w185, h632, original
}

public enum ImageSize {
    case poster(size: PosterSize), backdrop(size: BackdropSize), logo(size: LogoSize), profile(size: ProfileSize)

    public init(posterSize: PosterSize? = nil, backdropSize: BackdropSize? = nil, logoSize: LogoSize? = nil, profileSize: ProfileSize? = nil) {
        if let posterSize = posterSize {
            self = .poster(size: posterSize)
        } else if let backdropSize = backdropSize {
            self = .backdrop(size: backdropSize)
        } else if let logoSize = logoSize {
            self = .logo(size: logoSize)
        } else if let profileSize = profileSize {
            self = .profile(size: profileSize)
        } else {
            self = .backdrop(size: .w780)
        }
    }
}
