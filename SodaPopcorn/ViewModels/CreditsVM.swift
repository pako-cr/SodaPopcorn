//
//  CreditsVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 10/11/21.
//

import Combine
import Foundation

public protocol CreditsVMInputs: AnyObject {
    /// Call when the view did load.
    func viewDidLoad()

    /// Call when the close button is pressed.
    func closeButtonPressed()

    /// Call when a cast member is selected.
    func castMemberSelected(cast: Cast)
}

public protocol CreditsVMOutputs: AnyObject {
    /// Emits to close the screen.
    func closeButtonAction() -> PassthroughSubject<Void, Never>

    /// Emits to return the credits information.
    func creditsAction() -> PassthroughSubject<Credits, Never>

    /// Emits when loading.
    func loading() -> CurrentValueSubject<Bool, Never>

    /// Emits when an error occurred.
    func showError() -> PassthroughSubject<String, Never>

    /// Emits when a cast member is selected.
    func castMemberAction() -> PassthroughSubject<Person, Never>

    /// Emits to return the movie information.
    func movieAction() -> CurrentValueSubject<Movie, Never>
}

public protocol CreditsVMTypes: AnyObject {
    var inputs: CreditsVMInputs { get }
    var outputs: CreditsVMOutputs { get }
}

public final class CreditsVM: ObservableObject, Identifiable, CreditsVMInputs, CreditsVMOutputs, CreditsVMTypes {
    // MARK: Constants
    private let movie: Movie
    private let credits: Credits

    // MARK: Variables
    public var inputs: CreditsVMInputs { return self }
    public var outputs: CreditsVMOutputs { return self }

    // MARK: Variables
    private var cancellable = Set<AnyCancellable>()

    public init(movie: Movie, credits: Credits) {
        self.movie = movie
        self.credits = credits

        closeButtonPressedProperty.sink { [weak self] _ in
            self?.closeButtonActionProperty.send(())
        }.store(in: &cancellable)

        viewDidLoadProperty.sink { [weak self] _ in
            if let credits = self?.credits {
                self?.creditsActionProperty.send(credits)
            }
        }.store(in: &cancellable)

        castMemberSelectedProperty.sink { [weak self] cast in
            let person = Person(name: cast.name, id: cast.id)
            self?.castMemberActionProperty.send(person)
        }.store(in: &cancellable)
    }

    // MARK: - ⬇️ INPUTS Definition
    private let viewDidLoadProperty = PassthroughSubject<Void, Never>()
    public func viewDidLoad() {
        viewDidLoadProperty.send(())
    }

    private let closeButtonPressedProperty = PassthroughSubject<Void, Never>()
    public func closeButtonPressed() {
        closeButtonPressedProperty.send(())
    }

    private let castMemberSelectedProperty = PassthroughSubject<Cast, Never>()
    public func castMemberSelected(cast: Cast) {
        castMemberSelectedProperty.send(cast)
    }

    // MARK: - ⬆️ OUTPUTS Definition
    private let closeButtonActionProperty = PassthroughSubject<Void, Never>()
    public func closeButtonAction() -> PassthroughSubject<Void, Never> {
        return closeButtonActionProperty
    }

    private let creditsActionProperty = PassthroughSubject<Credits, Never>()
    public func creditsAction() -> PassthroughSubject<Credits, Never> {
        return creditsActionProperty
    }

    private let loadingProperty = CurrentValueSubject<Bool, Never>(false)
    public func loading() -> CurrentValueSubject<Bool, Never> {
        return loadingProperty
    }

    private let showErrorProperty = PassthroughSubject<String, Never>()
    public func showError() -> PassthroughSubject<String, Never> {
        return showErrorProperty
    }

    private let castMemberActionProperty = PassthroughSubject<Person, Never>()
    public func castMemberAction() -> PassthroughSubject<Person, Never> {
        return castMemberActionProperty
    }

    private lazy var movieActionProperty = CurrentValueSubject<Movie, Never>(self.movie)
    public func movieAction() -> CurrentValueSubject<Movie, Never> {
        return movieActionProperty
    }

    // MARK: - ⚙️ Helpers

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑", "CreditsVM deinit.")
    }
}
