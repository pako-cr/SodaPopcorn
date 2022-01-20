//
//  ImageSizeApi.swift
//  Networking
//
//  Created by Francisco Cordoba on 8/9/21.
//

import Foundation

public enum PosterSizeApi: String {
	case w92, w154, w185, w342, w500, w780, original
}

public enum BackdropSizeApi: String {
    case w300, w780, w1280, original
}

public enum LogoSizeApi: String {
    case w45, w92, w154, w185, w300, w500, original
}

public enum ProfileSizeApi: String {
    case w45, w185, h632, original
}

public enum ImageSizeApi {
    case poster(size: PosterSizeApi), backdrop(size: BackdropSizeApi), logo(size: LogoSizeApi), profile(size: ProfileSizeApi)

    public init(posterSize: PosterSizeApi? = nil, backdropSize: BackdropSizeApi? = nil, logoSize: LogoSizeApi? = nil, profileSize: ProfileSizeApi? = nil) {
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
