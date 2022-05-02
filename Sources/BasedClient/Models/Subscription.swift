//
//  Subscription.swift
//  
//
//  Created by Alexander van der Werff on 31/08/2021.
//

import Foundation

public typealias SubscriptionId = Int
public typealias SubscriberId = String
typealias Subscriptions = Dictionary<SubscriptionId, SubscriptionModel>

actor SubscriptionManager {
    private var subscriptions = Subscriptions()
    
    func getSubscriptions() -> Subscriptions {
        return subscriptions
    }
    
    func subscription(with id: SubscriptionId) -> SubscriptionModel? {
        return subscriptions[id]
    }
    
    func removeSubscription(with id: SubscriptionId) {
        subscriptions.removeValue(forKey: id)
    }
    
    func updateSubscription(with id: SubscriptionId, subscription: SubscriptionModel) {
        subscriptions[id] = subscription
    }
    
    @discardableResult
    func addSubscriber(for id: SubscriptionId, and subscriber: SubscriptionCallback) -> SubscriberId {
        let subscriberId = UUID().uuidString
        subscriptions[id]?.subscribers[subscriberId] = subscriber
        return subscriberId
    }
}

struct SubscriptionModel {
    var error: BasedError?
    var payload: JSON?
    let name: String?
    var subscribers: Dictionary<SubscriberId, SubscriptionCallback> = [:]
}

struct SubscriptionCallback {
    var onError: ErrorCallback?
    var onData: DataCallback?
}

enum SubscriptionType {
    case query(Query)
    case function(_ name: String, _ payload: Any?)
    
    func generateSubscriptionId() -> Int {
        switch self {
        case .query(let query):
            if let json = try? JSON(query.dictionary()) {
                return Current.hasher.hashObjectIgnoreKeyOrder(json)
            }
        case let .function(name, payload):
            if let payload = payload, let json = try? JSON(payload) {
                return Current.hasher.hashObjectIgnoreKeyOrder(JSON.array([JSON.string(name), json]))
            }
        }
        return 0
    }
}
