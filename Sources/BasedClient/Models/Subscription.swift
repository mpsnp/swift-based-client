//
//  Subscription.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//

struct Subscription {
    let authError: BasedError?
    let cnt: Int = 0
//    let query: GenericObject?
    let name: String?
    var subscribers: Dictionary<SubscriptionId, SubscriptionCallback> = [:]
}

struct SubscriptionCallback {
    var onInitial: InitialCallback?
    var onError: ErrorCallback?
    var onData: DataCallback?
}
