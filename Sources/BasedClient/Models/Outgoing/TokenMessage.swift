//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 27/09/2021.
//

import Foundation
import AnyCodable

struct TokenMessage: Message {
    var id: Int
    var requestType: RequestType { .token }
    let token: String?
    var checksum: Int?
    var codable: [AnyEncodable] {
        [AnyEncodable(requestType.rawValue), AnyEncodable(token), AnyEncodable(checksum)]
    }
}
