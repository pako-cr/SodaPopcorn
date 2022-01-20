//
//  AnyPublisher+Create.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/9/21.
//

import Combine
import Foundation

public struct AnyObserver<Output, Failure: Error> {
	public let onNext: ((Output) -> Void)
	public let onError: ((Failure) -> Void)
	public let onComplete: (() -> Void)
}

public struct Disposable {
	public let dispose: () -> Void

    public init() {
        self.dispose = {}
    }
}

extension AnyPublisher {
	public static func create(subscribe: @escaping (AnyObserver<Output, Failure>) -> Disposable) -> Self {
		let subject = PassthroughSubject<Output, Failure>()
		var disposable: Disposable?
		return subject
			.handleEvents(receiveSubscription: { _ in
				disposable = subscribe(AnyObserver(
					onNext: { output in subject.send(output) },
					onError: { failure in subject.send(completion: .failure(failure)) },
					onComplete: { subject.send(completion: .finished) }
				))
			}, receiveCancel: { disposable?.dispose() })
			.eraseToAnyPublisher()
	}
}
