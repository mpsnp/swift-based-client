//
//  Based+Subscriptions.swift
//  
//
//  Created by Alexander van der Werff on 13/09/2021.
//

import Foundation
import AnyCodable

extension Based {
    
    /**
     
     */
    func sendAllSubscriptions(reAuth: Bool = false) async {
        
        for (subscriptionId, subscription) in subscriptions {

            if (reAuth && subscription.error == nil) {
              // delete subscrption.authError
              continue
            }

            var getInQ: Message?, queued: Message?, getIndex: Int = 0

            let subscriptionMessages = await messages.allSubscriptionMessages()
            
            for (index, message) in subscriptionMessages.enumerated() {
                if message.id == subscriptionId {
                    if message.requestType == .getSubscription {
                        getIndex = index
                        getInQ = message
                    } else if message.requestType == .subscription {
                        queued = message
                    }
                }
            }
            
            if (getInQ != nil && queued != nil) {
                print("GET IN Q AND SUB IN Q SHOULD BE IMPOSSIBLE")
            }

            let cache = cache[subscriptionId]
            var x = false

            if getInQ != nil {
                var onlyGets = true
                for subscriber in subscription.subscribers {

                    if subscriber.value.onData != nil {
                        onlyGets = false
                        break
                    }
                }

                if onlyGets == true {
                  x = true
                } else {
                  await messages.removeSubscriptionMessage(at: getIndex)
                }

                if
                    let cacheChecksum = cache?.checksum,
                    let inQCheksum = getInQ?.checksum,
                    cacheChecksum != inQCheksum {
                        getInQ?.checksum = cache?.checksum
                }

            }
            
            if !x {
                if queued != nil {
                    if cache != nil && queued?.checksum != cache?.checksum {
                        queued?.checksum = cache?.checksum
                        if getInQ != nil, let subscribeMessage = queued as? SubscribeMessage {
                            queued = SubscribeMessage(id: subscribeMessage.id, payload: subscribeMessage.payload, checksum: subscribeMessage.checksum, requestMode: .sendDataBackWithSubscription, functionName: subscribeMessage.functionName)
                        }
                    }
                } else {
                    addToMessages(
                        SubscribeMessage(
                            id: subscriptionId,
                            payload: subscription.payload,
                            checksum: cache?.checksum != nil ? cache?.checksum : 0,
                            requestMode: getInQ != nil ? .sendDataBackWithSubscription : .dontSendBack,
                            functionName: subscription.name
                        )
                    )
                }
            }

        }
    }
    
    func generateSubscriptionId(payload: JSON, name: String?) -> Int {
        var array = [payload]
        if let name = name {
            array.insert(JSON.string(name), at: 0)
        }
        return Current.hasher.hashObjectIgnoreKeyOrder(JSON.array(array))
    }
    
    /**
     
     */
    func addSubscriber(
        payload: JSON,
        onData: @escaping DataCallback,
        onInitial: InitialCallback?,
        onError: ErrorCallback?,
        subscriptionId: SubscriptionId?,
        name: String?
    ) async -> (subscriptionId: Int, subscriberId: Int) {
        
        let finalSubscriptionId =
            subscriptionId
            ??
            self.generateSubscriptionId(payload: payload, name: name)
        
        var subscription = subscriptions[finalSubscriptionId]
        
        let cache = cache[finalSubscriptionId]
        
        var subscriberId: Int = 0
        
        let subscriptionMessages = await messages.allSubscriptionMessages()
        
        if let sub = subscription {
            subscriberId = sub.cnt + 1
            
            var onlyGets = true
            sub.subscribers.forEach { id, callback in
                if callback.onData != nil {
                    onlyGets = false
                }
            }
            
            subscription?.subscribers[subscriberId] = SubscriptionCallback(onInitial: onInitial, onError: onError, onData: onData)
            
            if onlyGets {
                
                try? await messages.removeAllSubscriptionMessages { message in
                    message.requestType == .getSubscription && message.id == finalSubscriptionId
                }
                
                let message = SubscribeMessage(id: finalSubscriptionId, payload: payload, checksum: cache?.checksum ?? 0, requestMode: .sendDataBackWithSubscription, functionName: name)
                addToMessages(message)
            }
            
        } else {
                
                subscriberId = 1
                subscriptions[finalSubscriptionId] = SubscriptionModel(
                    cnt: 1,
                    payload: payload,
                    name: name,
                    subscribers: [1: SubscriptionCallback(onInitial: onInitial, onError: onError, onData: onData)]
                )
                
                var dontSend = false
                var includeReply = false
                var subMsg: SubscribeMessage?
                var subscriptionsToDelete = [Message]()
            
                subscriptionMessages.forEach { message in
                    let type = message.requestType
                    let id = message.id
                    let checksum = message.checksum
                    if type == .unsubscribe || type == .sendSubscriptionData || type == .getSubscription && id == finalSubscriptionId {
                        if type == .getSubscription {
                            includeReply = true
                        }
                        subMsg?.requestMode = .sendDataBackWithSubscription
                        
                        subscriptionsToDelete.append(message)
                    } else if type == .subscription && id == finalSubscriptionId {
                        dontSend = true
                        
                        subMsg = message as? SubscribeMessage
                        
                        if checksum != cache?.checksum {
                            subMsg?.checksum = cache?.checksum
                        }
                        if subMsg?.requestMode != nil && includeReply {
                            subMsg?.requestMode = .sendDataBackWithSubscription
                        }
                    }
                }
                
                await messages.removeSubscriptionMessages(with: subscriptionsToDelete)
                
                if dontSend == false {
                    let requestMode: RequestMode = includeReply ? .sendDataBackWithSubscription : .dontSendBack
                    let message = SubscribeMessage(
                        id: finalSubscriptionId,
                        payload: payload,
                        checksum: cache?.checksum ?? 0,
                        requestMode: requestMode,
                        functionName: name
                    )
                    
                    addToMessages(message)
                }
                
                if let cache = cache {
                    onInitial?(nil, subscriptionId, subscriberId, nil, nil)
                    subscription?.subscribers[subscriberId]?.onInitial = nil
                    onData(cache.value, cache.checksum)
                }
            
        }
        
        return (finalSubscriptionId, subscriberId)
    }
    
    /**
     
     */
    func incomingSubscription(_ data: SubscriptionData) {
        guard let subscription = subscriptions[data.id] else { return }
        
        let previousChecksum = cache[data.id]?.checksum
        dataInfo("Checksum in. previous: \(String(describing: previousChecksum)). New \(String(describing: data.checksum)). Error: \(String(describing: data.error))")
        
        guard data.error == nil else {
            if data.error?.auth == true {
                subscriptions[data.id]?.error = .auth(token)
            }
            
            subscription.subscribers.forEach { subscriberId, callback in
                if data.error?.auth != true {
                    callback.onInitial?(.auth(token), data.id, subscriberId, nil, nil)
                    subscriptions[data.id]?.subscribers[subscriberId]?.onInitial = nil
                    
                    Task {
                        await removeSubscriber(subscriptionId: data.id, subscriberId: subscriberId)
                    }
                } else {
                    callback.onError?(.auth(token))
                }
                callback.onInitial?(.auth(token), data.id, subscriberId, nil, true)

                subscriptions[data.id]?.subscribers[subscriberId]?.onInitial = nil
            }
            
            return
        }
        
        if previousChecksum == data.checksum {
            
            subscriptions[data.id]?.error = nil
            
            subscription.subscribers.forEach { subscriberId, callback in
                if callback.onInitial != nil {
                    callback.onInitial?(nil, data.id, subscriberId, cache[data.id]?.value, nil)
                    subscriptions[data.id]?.subscribers[subscriberId]?.onInitial = nil
                    if callback.onData == nil {
                        Task {
                            await removeSubscriber(subscriptionId: data.id, subscriberId: subscriberId)
                        }
                    }
                }
            }
        } else {
            if subscription.error != nil {
                subscriptions[data.id]?.error = nil
            }
            
//            if let jsonData = try? JSON(data.data.value) {
//                cache[data.id] = (jsonData, data.checksum ?? 0)
//            }
            
            cache[data.id] = (data.data, data.checksum ?? 0)
            
            subscription.subscribers.forEach { subscriberId, callback in
                if callback.onInitial != nil {
                    callback.onInitial?(nil, data.id, subscriberId, data.data, nil)
                    subscriptions[data.id]?.subscribers[subscriberId]?.onInitial = nil
                    if callback.onData == nil {
                        Task {
                            await removeSubscriber(subscriptionId: data.id, subscriberId: subscriberId)
                        }
                    }
                }
                
                callback.onData?(data.data, data.checksum ?? 0)
            }
            
        }
    }
    
    /**
     
     */
    func incomingSubscriptionDiff(_ data: SubscriptionDiffData) {
        guard let subscription = subscriptions[data.id] else { return }
        
        var cache = cache[data.id]
        
        if cache == nil || cache?.checksum != data.checksums.previous {
            if cache != nil {
                if cache?.checksum == data.checksums.current {
                    subscription.subscribers.forEach { subscriberId, callback in
                        subscriptions[data.id]?
                            .subscribers[subscriberId]?
                            .onInitial?(nil, data.id, subscriberId, cache?.value, nil)
                        
                        subscriptions[data.id]?
                            .subscribers[subscriberId]?.onInitial = nil

                        if callback.onData == nil {
                            Task { await removeSubscriber(subscriptionId: data.id, subscriberId: subscriberId) }
                        }
                    }
                } else {
                    addToMessages(SendSubscriptionDataMessage(id: data.id, checksum: nil))
                }
            } else {
                addToMessages(SendSubscriptionDataMessage(id: data.id, checksum: nil))
            }
        } else {
            
            var isCorrupt = false
            if
                let value = cache?.value,
                let json = try? decoder.decode(JSON.self, from: value),
                let patched = Current.patcher.applyPatch(json, data.patchObject),
                let encodedPatch = try? encoder.encode(patched) {
                cache?.value = encodedPatch
            } else {
                isCorrupt = true
            }
            
            if isCorrupt == false {
                cache?.checksum = data.checksums.current
                subscription.subscribers.forEach { subscriberId, callback in
                    callback.onInitial?(nil, data.id, subscriberId, cache?.value, nil)
                    subscriptions[data.id]?
                        .subscribers[subscriberId]?.onInitial = nil
                    if callback.onData == nil {
                        Task { await removeSubscriber(subscriptionId: data.id, subscriberId: subscriberId) }
                    }
                    if let checksum = cache?.checksum, let value = cache?.value {
                        callback.onData?(value, checksum)
                    }
                }
            } else {
                self.cache.removeValue(forKey: data.id)
                addToMessages(SendSubscriptionDataMessage(id: data.id, checksum: nil))
            }
        }
    }
    
    /**
     
     */
    func removeSubscriber(subscriptionId: SubscriptionId, subscriberId: SubscriberId? = nil) async {
        if var subscription = subscriptions[subscriptionId] {
            var remove = false

            if let subscriberId = subscriberId, subscription.subscribers[subscriberId] != nil {
                subscription.subscribers.removeValue(forKey: subscriberId)
                subscription.cnt = subscription.cnt - 1
                if subscription.cnt <= 0 {
                    remove = true
                }
            } else {
                remove = true
            }

            if remove {
                subscriptions.removeValue(forKey: subscriptionId)
                var dontSend = false
                
                let subscriptionMessages = await messages.allSubscriptionMessages()
                
                for (index, subscriptionMessage) in subscriptionMessages.enumerated() {
                    switch subscriptionMessage {
                    case is UnsubscribeMessage where subscriptionMessage.id == subscriptionId:
                        dontSend = true
                    case is SubscribeMessage where subscriptionMessage.id == subscriptionId,
                        is SendSubscriptionDataMessage where subscriptionMessage.id == subscriptionId:
                        await messages.removeSubscriptionMessage(at: index)
                    default:
                        break
                    }
                }

                if !dontSend {
                    addToMessages(UnsubscribeMessage(id: subscriptionId))
                }
            }
        }
    }
}
