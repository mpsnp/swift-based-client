//
//  Based+Get.swift
//  
//
//  Created by Alexander van der Werff on 16/01/2022.
//

import Foundation

extension Based {
    
    public func get<T: Decodable>(name: String, payload: Any = [:]) async throws -> T {
        try await withCheckedThrowingContinuation { [decoder] continuation in
            Task {
                let payload = (try? JSON(payload)) ?? .null
                await addGetSubscriber(payload: payload, onData: { data, checksum in
                    guard let data = data as? Data else {
                        continuation.resume(throwing: BasedError.other(message: "Could not decode to \(T.self)"))
                        return
                    }
                    do {
                        let model = try decoder.decode(T.self, from: data)
                        continuation.resume(returning: model)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }, onError: { error in
                    continuation.resume(throwing: error)
                }, subscriptionId: nil, name: name)
            }
        }
    }
    
    public func get<T: Decodable>(query: Query) async throws -> T {
        let data = try await _get(query: query)
        return try decoder.decode(T.self, from: data)
    }
    
    private func _get(query: Query) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            let payload = (try? JSON(query.dictionary())) ?? .null
            addRequest(type: .get, payload: payload, continuation: continuation, name: "")
        }
    }
    
    private func addGetSubscriber(
        payload: JSON,
        onData: @escaping DataCallback,
        onError: ErrorCallback?,
        subscriptionId: SubscriptionId?,
        name: String?
    ) async {
        
        let finalSubscriptionId =
            subscriptionId
            ??
            self.generateSubscriptionId(payload: payload, name: name)

        let cache = await cache.fetch(with: finalSubscriptionId)
        var subscription = await subscriptionManager.subscription(with: finalSubscriptionId)
        
        if let sub = subscription {
            
            if let error = sub.error {
                if beingAuth {
                    onError?(error)
                } else {
                    await subscriptionManager
                        .addSubscriber(
                            for: finalSubscriptionId,
                            and: SubscriptionCallback(onError: onError, onData: onData)
                        )
                }
            } else if let cache = cache {
                onData(cache.value, cache.checksum)
            } else {
                await subscriptionManager
                    .addSubscriber(
                        for: finalSubscriptionId,
                        and: SubscriptionCallback(onError: onError, onData: onData)
                    )
            }
        } else {
            subscription = SubscriptionModel(
                payload: payload,
                name: name,
                subscribers: [:]
            )
            
            await subscriptionManager.updateSubscription(with: finalSubscriptionId, subscription: subscription!)
            await subscriptionManager.addSubscriber(for: finalSubscriptionId, and: SubscriptionCallback(onError: onError, onData: onData))
            
            var dontSend = false
            let subscriptionMessages = await messages.allSubscriptionMessages()
            var messagesToDelete = [Message]()
            var messageToUpdate = [Message]()
            
            subscriptionMessages.forEach { message in
                let type = message.requestType
                let id = message.id
                
                if (type == .unsubscribe || type == .sendSubscriptionData) && id == finalSubscriptionId {
                    messagesToDelete.append(message)
                } else if (type == .subscription || type == .getSubscription) && id == subscriptionId {
                    dontSend = true
                    if type == .subscription {
                        var updatedMessage = message
                        if let checksum = cache?.checksum, checksum != checksum {
                            updatedMessage.checksum = checksum
                        }
                        updatedMessage.requestMode = .sendDataBackWithSubscription
                        messageToUpdate.append(updatedMessage)
                    }
                }
            }
            
            await messages.removeSubscriptionMessages(with: messagesToDelete)
            await messages.updateSubscriptionMessages(with: messageToUpdate)
            
            if dontSend == false {
                let message = SendSubscriptionGetDataMessage(
                    id: finalSubscriptionId,
                    query: payload.asJsonObject,
                    checksum: cache?.checksum,
                    customObservableFuncName: name
                )
                
                addToMessages(message)
            }
        }
    }
    
}
