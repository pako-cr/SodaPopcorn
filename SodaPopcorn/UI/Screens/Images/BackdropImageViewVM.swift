//
//  BackdropImageViewVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

import Foundation
import Combine

public protocol BackdropImageViewVMInputs: AnyObject {
    /// Call when the view did load.
    func viewDidLoad()

    /// Call when the close button is pressed.
    func closeButtonPressed()
}

public protocol BackdropImageViewVMOutputs: AnyObject {
    /// Emits to close the screen.
    func closeButtonAction() -> PassthroughSubject<Void, Never>

    /// Emits to get return the image information.
    func imageURLAction() -> PassthroughSubject<String, Never>

    /// Emits when loading.
    func loading() -> CurrentValueSubject<Bool, Never>

    /// Emits when an error occurred.
    func showError() -> PassthroughSubject<String, Never>
}

public protocol BackdropImageViewVMTypes: AnyObject {
    var inputs: BackdropImageViewVMInputs { get }
    var outputs: BackdropImageViewVMOutputs { get }
}

public final class BackdropImageViewVM: ObservableObject, Identifiable, BackdropImageViewVMInputs, BackdropImageViewVMOutputs, BackdropImageViewVMTypes {
    // MARK: Constants
    let imageURL: String

    // MARK: Variables
    public var inputs: BackdropImageViewVMInputs { return self }
    public var outputs: BackdropImageViewVMOutputs { return self }

    // MARK: Variables
    private var cancellable = Set<AnyCancellable>()
    private var page = 0

    init(imageURL: String) {
        self.imageURL = imageURL

        viewDidLoadProperty.sink { [weak self] _ in
            guard let `self` = self else { return }
            self.imageURLActionProperty.send(self.imageURL)
        }.store(in: &cancellable)

        closeButtonPressedProperty.sink { [weak self] _ in
            self?.closeButtonActionProperty.send(())
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

    private let imageURLActionProperty = PassthroughSubject<String, Never>()
    public func imageURLAction() -> PassthroughSubject<String, Never> {
        return imageURLActionProperty
    }

    private let loadingProperty = CurrentValueSubject<Bool, Never>(false)
    public func loading() -> CurrentValueSubject<Bool, Never> {
        return loadingProperty
    }

    private let showErrorProperty = PassthroughSubject<String, Never>()
    public func showError() -> PassthroughSubject<String, Never> {
        return showErrorProperty
    }

    // MARK: - ⚙️ Helpers

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑", "BackdropImageViewVM deinit.")
    }
}
