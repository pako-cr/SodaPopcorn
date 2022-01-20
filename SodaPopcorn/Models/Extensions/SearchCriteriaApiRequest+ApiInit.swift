//
//  SearchCriteriaApiRequest+convenienceInit.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 13/1/22.
//

import Networking

extension SearchCriteriaApiRequest {
    init(searchCriteria: SearchCriteria) {
        switch searchCriteria {
        case .nowPlaying:
            self = .nowPlaying
        case .popular:
            self = .popular
        case .topRated:
            self = .topRated
        case .upcomming:
            self = .upcomming
        case .discover(let genre):
            let genreApiRequest = GenreApiRequest(id: genre.id, name: genre.name)
            self = .discover(genre: genreApiRequest)
        }
    }
}
