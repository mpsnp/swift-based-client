//
//  Subscription.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//

struct Subscription {
    let error: BasedError?
    let cnt: UInt64
    let query: BasedQuery
    let name: String?
    var subscribers: Dictionary<String, SubscriptionCallback> = [:]
}

struct SubscriptionCallback {
    var onInitial: InitialCallback?
    var onError: ErrorCallback?
    var onData: DataCallback?
}
