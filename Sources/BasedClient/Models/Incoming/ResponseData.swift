//
//  ResponseData.swift
//  
//
//  Created by Alexander van der Werff on 27/09/2021.
//

import Foundation

protocol ResponseData {
    var requestType: RequestType { get }
}

struct SubscriptionDiffData: ResponseData {
    var requestType: RequestType { .subscriptionDiff }
    let id: UInt64
    let patchObject: JSON
    let checksums: (previous: UInt64, current: UInt64)
}

struct SubscriptionData: ResponseData {
    var requestType: RequestType { .sendSubscriptionData }
    let id: UInt64
    let data: JSON
    var checksum: UInt64?
    let error: ErrorObject?
}

struct RequestData: ResponseData {
    let requestType: RequestType
    let callbackId: UInt64
    let payload: JSON
    let error: ErrorObject?
}

struct AuthorizedData: ResponseData {
    var requestType: RequestType { .token }
    let subscriptionIds: [UInt64]
}
