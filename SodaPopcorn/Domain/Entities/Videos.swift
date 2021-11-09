//
//  Videos.swift
//  SodaPopcorn
//
//  Created by Francisco Zimplifica on 9/11/21.
//

public final class Videos: Hashable {
    public var id: String?
    public var results: [Video]?

    private init(id: String?, results: [Video]?) {
        self.id = id
        self.results = results
    }

    convenience init(apiResponse: VideosApiResponse) {
        self.init(id: apiResponse.id,
                  results: apiResponse.results?.map({ Video(apiResponse: $0) }) ?? [])
    }

    convenience init() {
        self.init(id: nil, results: nil)
    }

    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    public static func == (lhs: Videos, rhs: Videos) -> Bool {
        return lhs.id == rhs.id
    }
}
