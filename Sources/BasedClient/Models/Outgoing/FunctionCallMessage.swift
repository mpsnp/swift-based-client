//
//  FunctionCallMessage.swift
//  
//
//  Created by Alexander van der Werff on 27/09/2021.
//

import Foundation
import AnyCodable
import NakedJson

struct FunctionCallMessage: SubscriptionMessage {
    var requestType: RequestType { .call }
    let id: Int
    let name: String
    let payload: Json?
    var checksum: Int?
    var codable: [AnyEncodable] {
        [AnyEncodable(requestType.rawValue), AnyEncodable(name), AnyEncodable(id), AnyEncodable(payload)]
    }
}
