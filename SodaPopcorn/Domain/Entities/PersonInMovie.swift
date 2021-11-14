//
//  PersonInMovie.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

struct PersonInMovie: Hashable {
    let cast, crew: [Movie]?
    let id: Int?

    init(cast: [Movie]? = nil, crew: [Movie]? = nil, id: Int? = nil) {
        self.cast = cast
        self.crew = crew
        self.id = id
    }

    init(apiResponse: PersonInMovieApiResponse) {
        self.init(cast: apiResponse.cast?.map({Movie(apiResponse: $0)}),
                  crew: apiResponse.crew?.map({Movie(apiResponse: $0)}),
                  id: apiResponse.id)
    }
}
