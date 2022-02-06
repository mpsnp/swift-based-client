//
//  Based+Observable.swift
//  
//
//  Created by Alexander van der Werff on 07/12/2021.
//

import AnyCodable

extension Based {
    public func observable(query: Query) -> Observable {
        return Observable(query: query, based: self)
    }

    public func observable(name: String, payload: Any?) -> Observable {
        return Observable(name: name, payload: payload, based: self)
    }
}

public class Subscription {
    private let based: Based
    private let subscriberId: SubscriberId
    private let subscriptionId: SubscriptionId
    public var closed = false
  
    init(subscriptionId: SubscriptionId, subscriberId: SubscriberId, based: Based) {
        self.subscriptionId = subscriptionId
        self.subscriberId = subscriberId
        self.based = based
    }

    func unsubscribe() {
        self.closed = true
        Task { await based.removeSubscriber(subscriptionId: subscriptionId, subscriberId: subscriberId) }
    }
}

public class Observable {
    private let subscriptionId: SubscriptionId
    private let type: SubscriptionType
    private let based: Based
    
    init(query: Query, based: Based) {
        self.type = .query(query)
        self.based = based
        subscriptionId = type.generateSubscriptionId()
    }
    
    init(name: String, payload: Any?, based: Based) {
        self.type = .func(name, payload)
        self.based = based
        subscriptionId = type.generateSubscriptionId()
    }
    
    deinit {
        
    }
    
    public func subscribe(
        onNext: @escaping DataCallback,
        onError: @escaping ErrorCallback
    ) async -> Subscription {
        var payload: JSON = JSON.null
        var name: String? = nil
        switch type {
        case .query(let query):
            if let p = try? JSON(query.dictionary()) {
                payload = p
            }
        case .func(let n, let pay):
            name = n
            if let pay = pay,  let p = try? JSON(pay) {
                payload = p
            }
        }
        let ids = await based.addSubscriber(
            payload: payload,
            onData: onNext,
            onInitial: { error, subscriptionId, subscriberId, data, isAuthError in
                if let error = error {
                    onError(error)
                }
            },
            onError: onError,
            subscriptionId: subscriptionId,
            name: name
        )
        return Subscription(subscriptionId: ids.subscriptionId, subscriberId: ids.subscriberId, based: based)
    }
}
