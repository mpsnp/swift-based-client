//
//  Based+Token.swift
//  
//
//  Created by Alexander van der Werff on 27/11/2021.
//

import Foundation
import AnyCodable


extension Based {
    
    
    /// sendToken
    /// - Parameters:
    ///   - token:
    ///   - options:
    func sendToken(_ token: String? = nil, _ options: SendTokenOptions? = nil) async {
        
        let subscriptions = await subscriptionManager.getSubscriptions()
        
        beingAuth = true
        if let token = token {
            self.token = token
            self.sendTokenOptions = options
        } else {
            var toBeDeleted = [SubscriptionId]()
            await cache.all().forEach { args in
                let (id , _) = args
                if subscriptions[id] != nil {
                    toBeDeleted.append(id)
                }
            }
            await cache.remove(ids: toBeDeleted)
            
            self.token = nil
            self.sendTokenOptions = nil
        }
        if socket.connected {
            var message = [AnyCodable(RequestType.token.rawValue)]
            if let token = token {
                message = [AnyCodable(RequestType.token.rawValue), AnyCodable(token)]
            }
            let jsonData = try! JSONEncoder().encode(message)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                socket.send(message: .string(jsonString))
                socket.idleTimeout()
                Task { await sendAllSubscriptions(reAuth: true) }
            }
        }
    }
    
    
    ///
    /// - Parameter data:
    func logoutSubscriptions(_ data: [Int]) async {
        
        let subscriptions = await subscriptionManager.getSubscriptions()
        var toBeDeletedCache = [SubscriptionId]()
        
        for id in data {
            toBeDeletedCache.append(id)
            var subscription = subscriptions[id]
            subscription?.error = BasedError.authorization(notAuthenticated: true, message: "Unauthorized request")
            if let subscription = subscription {
                await subscriptionManager.updateSubscription(with: id, subscription: subscription)
            }
            
            subscription?.subscribers.forEach({ (id, callback) in
                callback.onError?(BasedError.auth(token: token))
            })
        }
        
        await cache.remove(ids: toBeDeletedCache)
    }
}

public struct SendTokenOptions {
    public let isBasedUser: Bool
    public init(isBasedUser: Bool) {
        self.isBasedUser = isBasedUser
    }
}
