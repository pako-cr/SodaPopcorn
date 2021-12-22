//
//  Backdrop.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

public struct Backdrop: Hashable {
    public let filePath: String?

    public init(filePath: String? = nil) {
        self.filePath = filePath
    }

    public init(apiResponse: BackdropApiResponse) {
        self.init(filePath: apiResponse.filePath)
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(filePath)
    }
}

extension Backdrop: Equatable {
    public static func == (lhs: Backdrop, rhs: Backdrop) -> Bool {
        return lhs.filePath == rhs.filePath
    }
}
