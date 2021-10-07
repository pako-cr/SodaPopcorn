//
//  MovieDetailsVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 7/10/21.
//

import Foundation
import Combine

public protocol MovieDetailsVMInputs: AnyObject {
	/// Call when the view did load.
	func viewDidLoad()

	/// Call when the close button is pressed.
	func closeButtonPressed()
}

public protocol MovieDetailsVMOutputs: AnyObject {
	/// Emits to close the screen.
	func closeButtonAction() -> PassthroughSubject<Void, Never>

	/// Emits to get return the movie information.
	func movieInfoAction() -> CurrentValueSubject<Movie?, Never>

	/// Emits when loading.
	func loading() -> CurrentValueSubject<Bool, Never>
}

public protocol MovieDetailsVMTypes: AnyObject {
	var inputs: MovieDetailsVMInputs { get }
	var outputs: MovieDetailsVMOutputs { get }
}

public final class MovieDetailsVM: ObservableObject, Identifiable, MovieDetailsVMInputs, MovieDetailsVMOutputs, MovieDetailsVMTypes {
	// MARK: Constants
	private let movie: Movie

	// MARK: Variables
	public var inputs: MovieDetailsVMInputs { return self }
	public var outputs: MovieDetailsVMOutputs { return self }

	// MARK: Variables
	private var cancellable = Set<AnyCancellable>()
	private var page = 0

	init(movie: Movie) {
		self.movie = movie

		viewDidLoadProperty.sink { [weak self] _ in
			guard let `self` = self else { return }
			self.movieInfoActionProperty.value = self.movie
		}.store(in: &cancellable)

		closeButtonPressedProperty.sink { [weak self] _ in
			guard let `self` = self else { return }
			self.closeButtonActionProperty.send(())
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

	// MARK: - ⬆️ OUTPUTS Definition
	private let closeButtonActionProperty = PassthroughSubject<Void, Never>()
	public func closeButtonAction() -> PassthroughSubject<Void, Never> {
		return closeButtonActionProperty
	}

	private let movieInfoActionProperty = CurrentValueSubject<Movie?, Never>(nil)
	public func movieInfoAction() -> CurrentValueSubject<Movie?, Never> {
		return movieInfoActionProperty
	}

	private let loadingProperty = CurrentValueSubject<Bool, Never>(false)
	public func loading() -> CurrentValueSubject<Bool, Never> {
		return loadingProperty
	}

	// MARK: - ⚙️ Helpers

	// MARK: - 🗑 Deinit
	deinit {
		print("🗑", "MovieDetailsVM deinit.")
	}
}
