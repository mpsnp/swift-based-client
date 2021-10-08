//
//  FunctionCallMessage.swift
//  
//
//  Created by Alexander van der Werff on 27/09/2021.
//

import Foundation
import AnyCodable

struct FunctionCallMessage: Message {
    var requestType: RequestType { .call }
    let name: String
    var checksum: UInt64?
    let payload: [String: Any]
    var codable: [AnyCodable] {
        [AnyCodable(requestType.rawValue), AnyCodable(name), AnyCodable(checksum), AnyCodable(payload)]
    }
}
