//
//  Backdrop.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

public final class Backdrop: Hashable {
    public var filePath: String?

    private init(filePath: String? = nil) {
        self.filePath = filePath
    }

    convenience init(apiResponse: BackdropApiResponse) {
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
