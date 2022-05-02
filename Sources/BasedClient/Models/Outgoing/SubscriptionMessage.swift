//
//  SubscriptionMessage.swift
//  
//
//  Created by Alexander van der Werff on 13/09/2021.
//

import Foundation
import AnyCodable

// Outgoing data

// 0 = don't send data back if the same checksum but make subscription
// 1 = send data back, do not make a subscription
// 2 = allways send data back, make subscription
enum RequestMode: Int, Codable {
    case dontSendBack = 0
    case sendDataBack = 1
    case sendDataBackWithSubscription = 2
}

protocol Message {
    var requestType: RequestType { get }
    var id: Int { get }
    var checksum: Int? { get set }
    var codable: [AnyEncodable] { get }
}

protocol SubscriptionMessage: Message {}

struct RequestMessage: Message {
    let requestType: RequestType
    let id: Int
    let payload: JSON?
    var checksum: Int? = nil
    var codable: [AnyEncodable] {
        [AnyEncodable(requestType.rawValue), AnyEncodable(id), AnyEncodable(payload?.asJsonValue), AnyEncodable(checksum)]
    }
}

struct SubscribeMessage: SubscriptionMessage {
    var requestType: RequestType { .subscription }
    let id: Int
    let payload: JSON?
    var checksum: Int?
    var requestMode: RequestMode?
    let functionName: String?
    var codable: [AnyEncodable] {
        [
            AnyEncodable(requestType.rawValue),
            AnyEncodable(id),
            AnyEncodable(payload?.asJsonValue),
            AnyEncodable(checksum),
            AnyEncodable(requestMode),
            AnyEncodable(functionName)
        ]
    }
}

struct SendSubscriptionDataMessage: SubscriptionMessage {
    var requestType: RequestType { .sendSubscriptionData }
    let id: Int
    var checksum: Int?
    var codable: [AnyEncodable] {
        [AnyEncodable(requestType.rawValue), AnyEncodable(id), AnyEncodable(checksum)]
    }
}

struct SendSubscriptionGetDataMessage: SubscriptionMessage {
    var requestType: RequestType { .getSubscription }
    let id: Int
    let query: [String: Any]?
    var checksum: Int?
    let customObservableFuncName: String?
    var codable: [AnyEncodable] {
        [
            AnyEncodable(requestType.rawValue),
            AnyEncodable(id),
            AnyEncodable(query),
            AnyEncodable(checksum),
            AnyEncodable(customObservableFuncName)
        ]
    }
}

struct UnsubscribeMessage: SubscriptionMessage {
    var requestType: RequestType { .unsubscribe }
    let id: Int
    var checksum: Int?
    var codable: [AnyEncodable] {
        [AnyEncodable(requestType.rawValue), AnyEncodable(id)]
    }
}
