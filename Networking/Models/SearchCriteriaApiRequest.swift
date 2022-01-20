//
//  SearchCriteriaApiRequest.swift
//  Networking
//
//  Created by Francisco Cordoba on 13/1/22.
//

public enum SearchCriteriaApiRequest {
    case nowPlaying, discover(genre: GenreApiRequest), topRated, upcomming, popular
}
