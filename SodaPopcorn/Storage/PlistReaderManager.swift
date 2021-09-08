//
//  PlistReaderManager.swift
//  SodaPopcorn
//
//  Created by Zimplifica Macbook Pro on 8/9/21.
//

import Foundation

class PlistReaderManager {
	private enum Error: Swift.Error {
		case fileMissing
	}

	private let bundle: Bundle

	public static let shared: PlistReaderManager = {
		return PlistReaderManager()
	}()

	private init() {
		self.bundle = Bundle.main
	}

	/// Read a specific plist configuration file with file name equals fileNamed.
	private func read(with fileName: String) throws -> [String: Any] {
		guard let path = bundle.path(forResource: fileName, ofType: "plist"),
			  let plistData = FileManager.default.contents(atPath: path) else {
			throw Error.fileMissing
		}

		var format = PropertyListSerialization.PropertyListFormat.xml

		return try PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: &format) as? [String: Any] ?? [:]
	}

	/// Read a container directly from the "Info.plist" configuration file.
	func read(fromContainer named: String) throws -> [String: Any] {
		do {
			let containers = try read(with: "Info") as [String: Any]
			return containers[named] as? [String: Any] ?? [:]

		} catch let error {
			throw NSError(domain: "Error reading plist container. Error: \(error.localizedDescription)", code: 1, userInfo: [:])
		}
	}

	func read(fromOptionName option: String) throws -> Any? {
		do {
			let containers = try read(with: "Info") as [String: Any]
			return containers[option] as Any?

		} catch let error {
			throw NSError(domain: "Error reading plist container. Error: \(error.localizedDescription)", code: 1, userInfo: [:])
		}
	}

	/// Read a container's leaf directly from the "Info.plist" configuration file.
	func read(fromContainer named: String, with leafName: String) throws -> Any {
		do {
			let plist = try read(with: "Info") as [String: Any]
			let container = plist[named] as? [String: Any] ?? [:]
			return container[leafName] as Any

		} catch let error {
			throw NSError(domain: "Error reading plist container. Error: \(error.localizedDescription)", code: 1, userInfo: [:])
		}
	}
}
