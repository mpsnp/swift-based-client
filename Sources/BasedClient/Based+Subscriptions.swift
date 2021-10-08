//
//  Based+Subscriptions.swift
//  
//
//  Created by Alexander van der Werff on 13/09/2021.
//

import Foundation

extension Based {
    func sendAllSubscriptions(reAuth: Bool = false) {
        
//        for (subscriptionId, subscription) in subscriptions {
//
//            if (reAuth && subscription.error == nil) {
//              // delete subscrption.authError
//              continue
//            }
//
//            var getInQ: SubscriptionMessage?, queued: SubscriptionMessage?, getIndex: Int = 0
//
//            for (index, message) in subscriptionQueue.enumerated() {
//                if message.subscriptionId == subscriptionId {
//                    if message.requestType == .getSubscription {
//                        getIndex = index
//                        getInQ = message
//                    } else if message.requestType == .subscription {
//                        queued = message
//                    }
//                }
//            }
//
//            let cache = cache[subscriptionId]
//            var x = false
//
//            if getInQ != nil {
//                var onlyGets = true
//                for subscriber in subscription.subscribers {
//
//                    if subscriber.value.onData != nil {
//                        onlyGets = false
//                        break
//                    }
//                }
//
//                if onlyGets == true {
//                  x = true
//                } else {
//                  subscriptionQueue.remove(at: getIndex)
//                }
//
//                if let cacheChecksum = cache?.checksum, let inQCheksum = getInQ?.checksum, cacheChecksum != inQCheksum {
//                    getInQ?.checksum = cache?.checksum
//                }
//
//            }
//
//            if !x {
//                if queued != nil {
//                    if queued?.checksum! == cache?.checksum {
//                        queued?.checksum = cache?.checksum
//                        if getInQ != nil {
//                            (queued as? SubscribeMessage)?.requestMode = .back
//                        }
//                    }
//                } else {
//                    if subscriptions[subscriptionId]?.name {
//
//                        if cache != nil {
//                            addToQueue(client, [
//                            RequestTypes.Subscription,
//                            subscriptionId,
//                            query,
//                            cache.checksum,
//                            getInQ ? 2 : 0,
//                            name,
//                            ])
//                        } else {
//                            addToQueue(client, [
//                            RequestTypes.Subscription,
//                            subscriptionId,
//                            query,
//                            0,
//                            getInQ ? 2 : 0,
//                            name,
//                            ])
//                            }
//                    } else {
//                        if cache != nil {
//                        addToQueue(client, [
//                        RequestTypes.Subscription,
//                        subscriptionId,
//                        query,
//                        cache.checksum,
//                        getInQ ? 2 : 0,
//                        ])
//                        } else {
//                        addToQueue(client, [
//                        RequestTypes.Subscription,
//                        subscriptionId,
//                        query,
//                        0,
//                        getInQ ? 2 : 0,
//                        ])
//                    }
//                }
//            }
//
//        }
//
    }
}
