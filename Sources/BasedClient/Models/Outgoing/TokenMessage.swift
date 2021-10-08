//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 27/09/2021.
//

import Foundation
import AnyCodable

struct TokenMessage: Message {
    var requestType: RequestType { .token }
    let token: String?
    var checksum: UInt64?
    var codable: [AnyCodable] {
        [AnyCodable(requestType.rawValue), AnyCodable(token), AnyCodable(checksum)]
    }
}
