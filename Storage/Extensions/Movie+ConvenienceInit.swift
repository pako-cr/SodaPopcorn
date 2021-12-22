//
//  Movie+ConvenienceInit.swift
//  Storage
//
//  Created by Francisco Cordoba on 3/12/21.
//

import Domain

extension Movie {
    public init(movieStorageEntity: MovieStorageEntity) {
        self.init(
            movieId: movieStorageEntity.movieId,
            title: movieStorageEntity.title,
            overview: movieStorageEntity.overview,
            rating: movieStorageEntity.rating,
            posterPath: movieStorageEntity.posterPath,
            releaseDate: movieStorageEntity.releaseDate,
            voteCount: movieStorageEntity.voteCount,
            adult: movieStorageEntity.adult)
    }
}
