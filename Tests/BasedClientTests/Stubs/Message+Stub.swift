//
//  Message+Stub.swift
//  
//
//  Created by Alexander van der Werff on 01/02/2022.
//

import Foundation
import AnyCodable

@testable import BasedClient

struct StubMessage: Message {
    var id: Int
    let requestType: RequestType
    var checksum: Int?
    var codable: [AnyEncodable] {
        [AnyEncodable(requestType.rawValue)]
    }
    
    static func random() -> Self {
        let types = RequestType.allCases
        let random = Int.random(in: 0..<types.count)
        return Self(id: UUID().hashValue, requestType: types[random], checksum: 0)
    }
    
    static func subscribeMessage() -> SubscribeMessage {
        SubscribeMessage(id: UUID().hashValue, payload: nil, checksum: 0, requestMode: .sendDataBack, functionName: "name")
    }
}
