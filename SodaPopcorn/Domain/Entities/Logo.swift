//
//  Logo.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

public final class Logo: Hashable {
    public var filePath: String?

    private init(filePath: String? = nil) {
        self.filePath = filePath
    }

    convenience init(logoApiResponse: LogoApiResponse) {
        self.init(filePath: logoApiResponse.filePath)
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(filePath)
    }
}

extension Logo: Equatable {
    public static func == (lhs: Logo, rhs: Logo) -> Bool {
        return lhs.filePath == rhs.filePath
    }
}
