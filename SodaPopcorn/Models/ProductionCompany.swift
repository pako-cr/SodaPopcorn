//
//  ProductionCompany.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/11/21.
//

public struct ProductionCompany {
    public let id: Int?
    public let logoPath, name: String?

    public init(id: Int?, logoPath: String?, name: String?) {
        self.id = id
        self.name = name
        self.logoPath = logoPath
    }
}

extension ProductionCompany: Equatable {
    public static func == (lhs: ProductionCompany, rhs: ProductionCompany) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
