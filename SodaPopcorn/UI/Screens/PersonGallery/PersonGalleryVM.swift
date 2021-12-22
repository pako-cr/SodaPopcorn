//
//  PersonPersonGalleryVM.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 12/11/21.
//

import Combine
import Domain
import Foundation

public protocol PersonGalleryVMInputs: AnyObject {
    /// Call when the view did load.
    func viewDidLoad()

    /// Call when the close button is pressed.
    func closeButtonPressed()

    /// Call when an image is selected.
    func imageSelected(imageUrl: String)
}

public protocol PersonGalleryVMOutputs: AnyObject {
    /// Emits to close the screen.
    func closeButtonAction() -> PassthroughSubject<Void, Never>

    /// Emits to return the images information.
    func imagesAction() -> CurrentValueSubject<[PersonImage], Never>

    /// Emits when a person image is selected.
    func imageAction() -> PassthroughSubject<(String, [String]), Never>

    /// Emits to return the person.
    func personAction() -> CurrentValueSubject<Person, Never>
}

public protocol PersonGalleryVMTypes: AnyObject {
    var inputs: PersonGalleryVMInputs { get }
    var outputs: PersonGalleryVMOutputs { get }
}

public final class PersonGalleryVM: ObservableObject, Identifiable, PersonGalleryVMInputs, PersonGalleryVMOutputs, PersonGalleryVMTypes {
    // MARK: Constants
    private let personImages: [PersonImage]
    private let person: Person

    // MARK: Variables
    public var inputs: PersonGalleryVMInputs { return self }
    public var outputs: PersonGalleryVMOutputs { return self }

    // MARK: Variables
    private var cancellable = Set<AnyCancellable>()

    public init(person: Person, personImages: [PersonImage]) {
        self.personImages = personImages
        self.person = person

        closeButtonPressedProperty.sink { [weak self] _ in
            self?.closeButtonActionProperty.send(())
        }.store(in: &cancellable)

        imageSelectedProperty.sink { [weak self] imageUrl in
            guard let `self` = self else { return }
            let images = self.personImages.filter({ $0.filePath != "" }).map({ $0.filePath ?? "" })

            if !images.isEmpty {
                self.imageActionProperty.send((imageUrl, images))
            }
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

    private let imageSelectedProperty = PassthroughSubject<String, Never>()
    public func imageSelected(imageUrl: String) {
        imageSelectedProperty.send(imageUrl)
    }

    private let posterImageSelectedProperty = PassthroughSubject<String, Never>()
    public func posterImageSelected(imageURL: String) {
        posterImageSelectedProperty.send(imageURL)
    }

    private let videoSelectedProperty = PassthroughSubject<String, Never>()
    public func videoSelected(videoURL: String) {
        videoSelectedProperty.send(videoURL)
    }

    // MARK: - ⬆️ OUTPUTS Definition
    private let closeButtonActionProperty = PassthroughSubject<Void, Never>()
    public func closeButtonAction() -> PassthroughSubject<Void, Never> {
        return closeButtonActionProperty
    }

    private lazy var imagesActionProperty = CurrentValueSubject<[PersonImage], Never>(self.personImages)
    public func imagesAction() -> CurrentValueSubject<[PersonImage], Never> {
        return imagesActionProperty
    }

    private let imageActionProperty = PassthroughSubject<(String, [String]), Never>()
    public func imageAction() -> PassthroughSubject<(String, [String]), Never> {
        return imageActionProperty
    }

    private lazy var personActionProperty = CurrentValueSubject<Person, Never>(self.person)
    public func personAction() -> CurrentValueSubject<Person, Never> {
        return personActionProperty
    }

    // MARK: - ⚙️ Helpers

    // MARK: - 🗑 Deinit
    deinit {
        print("🗑", "PersonGalleryVM deinit.")
    }
}
