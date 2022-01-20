//
//  SearchObject.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 18/11/21.
//

public struct SearchObject: Hashable {
    public var movie: Movie?
    public var genre: Genre?

    public init(movie: Movie?) {
        self.movie = movie
    }

    public init(genre: Genre?) {
        self.genre = genre
    }
}
