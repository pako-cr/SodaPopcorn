//
//  ProductionCompany.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 3/11/21.
//

struct ProductionCompany {
    let id: Int?
    let logoPath, name: String?

    init(id: Int?, logoPath: String?, name: String?) {
        self.id = id
        self.name = name
        self.logoPath = logoPath
    }

    init(apiResponse: ProductionCompanyApiResponse) {
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
