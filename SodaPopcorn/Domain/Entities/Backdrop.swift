//
//  Backdrop.swift
//  SodaPopcorn
//
//  Created by Francisco Cordoba on 5/11/21.
//

import Foundation

public final class Backdrop: Codable, Hashable {
    public var id: String?
    public var filePath: String?
    
    private enum BackdropCodingKeys: String, CodingKey {
        case id
        case filePath = "file_path"
    }
    
    required public init(from decoder: Decoder) throws {
        let backdropContainer = try decoder.container(keyedBy: BackdropCodingKeys.self)
        
        id = try String(backdropContainer.decode(Int.self, forKey: .id))
        filePath = try backdropContainer.decodeIfPresent(String.self, forKey: .filePath)
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    public static func == (lhs: Backdrop, rhs: Backdrop) -> Bool {
        return lhs.id == rhs.id
    }
}
