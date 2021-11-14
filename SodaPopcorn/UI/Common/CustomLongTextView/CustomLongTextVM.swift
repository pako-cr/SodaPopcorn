//
//  CustomLongTextVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 11/11/21.
//

import Foundation
import Combine

public protocol CustomLongTextVMInputs: AnyObject {
    /// Call when the view did load.
    func viewDidLoad()

    /// Call when the close button is pressed.
    func closeButtonPressed()
}

public protocol CustomLongTextVMOutputs: AnyObject {
    /// Emits to close the screen.
    func closeButtonAction() -> PassthroughSubject<Void, Never>

    /// Emits to return the text information.
    func textAction() -> PassthroughSubject<String, Never>
}

public protocol CustomLongTextVMTypes: AnyObject {
    var inputs: CustomLongTextVMInputs { get }
    var outputs: CustomLongTextVMOutputs { get }
}

public final class CustomLongTextVM: ObservableObject, Identifiable, CustomLongTextVMInputs, CustomLongTextVMOutputs, CustomLongTextVMTypes {
    // MARK: Constants

    // MARK: Variables
    public var inputs: CustomLongTextVMInputs { return self }
    public var outputs: CustomLongTextVMOutputs { return self }

    // MARK: Variables
    private var cancellable = Set<AnyCancellable>()

    public init(text: String) {
        closeButtonPressedProperty.sink { [weak self] _ in
            self?.closeButtonActionProperty.send(())
        }.store(in: &cancellable)

        viewDidLoadProperty.sink { [weak self] _ in
            self?.textActionProperty.send(text)
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

    private let textActionProperty = PassthroughSubject<String, Never>()
    public func textAction() -> PassthroughSubject<String, Never> {
        return textActionProperty
    }

    // MARK: - ⚙️ Helpers

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑", "CustomLongTextVM deinit.")
    }
}
