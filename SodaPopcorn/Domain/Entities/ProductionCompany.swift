//
//  ProductionCompany.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/11/21.
//

public final class ProductionCompany {
    public var id: Int?
    public var logoPath: String?
    public var name: String?

    private init(id: Int?, logoPath: String?, name: String?) {
        self.id = id
        self.logoPath = logoPath
        self.name = name
    }

    convenience init(apiResponse: ProductionCompanyApiResponse) {
        self.init(id: apiResponse.id,
                  logoPath: apiResponse.logoPath,
                  name: apiResponse.name)
    }
}

extension ProductionCompany: Equatable {
    public static func == (lhs: ProductionCompany, rhs: ProductionCompany) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}
