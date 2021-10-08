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
// 2 = allways send data back, make subscription
// 1 = send data back, do not make a subscription
enum RequestMode: Int, Codable {
    case send = 0, roundtrip, back
}

protocol Message {
    var requestType: RequestType { get }
    var checksum: UInt64? { get set }
    var codable: [AnyCodable] { get }
}

protocol SubscriptionMessage: Message {
    var subscriptionId: UInt64 { get }
}

struct RequestMessage: Message {
    let requestType: RequestType
    var checksum: UInt64?
    let data: AnyCodable
    var codable: [AnyCodable] {
        [AnyCodable(requestType.rawValue), AnyCodable(checksum), AnyCodable(data)]
    }
}

struct SubscribeMessage: SubscriptionMessage {
    var requestType: RequestType { .subscription }
    let subscriptionId: UInt64
    let query: BasedQuery?
    var checksum: UInt64?
    var requestMode: RequestMode?
    let customObservableFunc: String?
    var codable: [AnyCodable] {
        [AnyCodable(requestType.rawValue), AnyCodable(subscriptionId), AnyCodable(query?.dictionary()), AnyCodable(checksum), AnyCodable(requestMode), AnyCodable(customObservableFunc)]
    }
}

struct SendSubscriptionDataMessage: SubscriptionMessage {
    var requestType: RequestType { .sendSubscriptionData }
    let subscriptionId: UInt64
    var checksum: UInt64?
    var codable: [AnyCodable] {
        [AnyCodable(requestType.rawValue), AnyCodable(subscriptionId), AnyCodable(checksum)]
    }
}

struct SendSubscriptionGetDataMessage: SubscriptionMessage {
    var requestType: RequestType { .getSubscription }
    let subscriptionId: UInt64
    let query: BasedQuery?
    var checksum: UInt64?
    let customObservableFunc: String?
    var codable: [AnyCodable] {
        [AnyCodable(requestType.rawValue), AnyCodable(subscriptionId), AnyCodable(query?.dictionary()), AnyCodable(checksum), AnyCodable(customObservableFunc)]
    }
}

struct UnsubscribeMessage: SubscriptionMessage {
    var requestType: RequestType { .unsubscribe }
    let subscriptionId: UInt64
    var checksum: UInt64?
    var codable: [AnyCodable] {
        [AnyCodable(requestType.rawValue), AnyCodable(subscriptionId), AnyCodable(checksum)]
    }
}
