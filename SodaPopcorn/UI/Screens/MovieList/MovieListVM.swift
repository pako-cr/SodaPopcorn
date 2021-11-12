//
//  MovieListVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

import Foundation
import Combine

public protocol MoviesListVMInputs: AnyObject {
    /// Call when the view did load.
    func viewDidLoad()

    /// Call when the close button is pressed.
    func closeButtonPressed()

    /// Call when a movie is selected.
    func movieSelected(movie: Movie)
}

public protocol MoviesListVMOutputs: AnyObject {
    /// Emits to close the screen.
    func closeButtonAction() -> PassthroughSubject<Void, Never>

    /// Emits to return the movies.
    func moviesAction() -> CurrentValueSubject<[Movie], Never>

    /// Emits when a movie is selected.
    func movieSelectedAction() -> PassthroughSubject<Movie, Never>
}

public protocol MoviesListVMTypes: AnyObject {
    var inputs: MoviesListVMInputs { get }
    var outputs: MoviesListVMOutputs { get }
}

public final class MoviesListVM: ObservableObject, Identifiable, MoviesListVMInputs, MoviesListVMOutputs, MoviesListVMTypes {
    // MARK: Constants
    private let movies: [Movie]

    // MARK: Variables
    public var inputs: MoviesListVMInputs { return self }
    public var outputs: MoviesListVMOutputs { return self }

    // MARK: Variables
    private var cancellable = Set<AnyCancellable>()

    public init(movies: [Movie]) {
        self.movies = movies

        self.movieSelectedProperty
            .sink { [weak self] movie in
                guard let `self` = self else { return }
                self.movieSelectedActionProperty.send(movie)
            }.store(in: &cancellable)

        self.closeButtonPressedProperty
            .sink { [weak self] _ in
                self?.closeButtonActionProperty.send(())
            }.store(in: &cancellable)

//        self.viewDidLoadProperty
//            .sink { [weak self] _ in
//                self?.moviesActionProperty.value = movies
//            }.store(in: &cancellable)
    }

    // MARK: - ⬇️ INPUTS Definition
    private let viewDidLoadProperty = PassthroughSubject<Void, Never>()
    public func viewDidLoad() {
        viewDidLoadProperty.send(())
    }

    private let movieSelectedProperty = PassthroughSubject<Movie, Never>()
    public func movieSelected(movie: Movie) {
        movieSelectedProperty.send(movie)
    }

    private let closeButtonPressedProperty = PassthroughSubject<Void, Never>()
    public func closeButtonPressed() {
        closeButtonPressedProperty.send(())
    }

    // MARK: - ⬆️ OUTPUTS Definition
    private let closeButtonActionProperty = PassthroughSubject<Void, Never>()
    public func closeButtonAction() -> PassthroughSubject<Void, Never> {
        return closeButtonActionProperty
    }

    private lazy var moviesActionProperty = CurrentValueSubject<[Movie], Never>(self.movies)
    public func moviesAction() -> CurrentValueSubject<[Movie], Never> {
        return moviesActionProperty
    }

    private let movieSelectedActionProperty = PassthroughSubject<Movie, Never>()
    public func movieSelectedAction() -> PassthroughSubject<Movie, Never> {
        return movieSelectedActionProperty
    }

    // MARK: - ⚙️ Helpers

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑", "MoviesListVM deinit.")
    }
}
