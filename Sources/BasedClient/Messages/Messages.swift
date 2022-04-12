//
//  Messages.swift
//  
//
//  Created by Alexander van der Werff on 01/02/2022.
//

import Foundation

actor Messages {
    private var messages = [Message]()
    private var subscriptionMessages = [Message]()
    
    func add(_ message: Message) {
        if message is SubscriptionMessage, message.requestType == .unsubscribe
            || message.requestType == .subscription
            || message.requestType == .sendSubscriptionData
            || message.requestType == .getSubscription {
            subscriptionMessages.append(message)
        } else {
            messages.append(message)
        }
    }
    
    func allSubscriptionMessages() -> [SubscribeMessage] {
        subscriptionMessages as? [SubscribeMessage] ?? []
    }
    
    func removeSubscriptionMessage(at index: Int) {
        subscriptionMessages.remove(at: index)
    }
    
    func removeSubscriptionMessages(with type: RequestType) {
        subscriptionMessages.removeAll { message in
            message.requestType == type
        }
    }
    
    func removeAllSubscriptionMessages(where shouldBeRemoved: (Message) throws -> Bool) throws {
        try subscriptionMessages.removeAll(where: shouldBeRemoved)
    }
    
    func removeSubscriptionMessages(with messages: [Message]) {
        subscriptionMessages = subscriptionMessages.filter({ item in !messages.contains(where: { $0.id == item.id }) })
    }
    
    func updateSubscriptionMessages(with messages: [Message]) {
        subscriptionMessages = subscriptionMessages
            .filter({ item in !messages.contains(where: { $0.id == item.id }) })
        subscriptionMessages.append(contentsOf: messages)
    }
    
    func popAll() -> [Message] {
        let all = messages + subscriptionMessages
        messages = []
        subscriptionMessages = []
        return all
    }
    
    func messageCount() -> Int {
        messages.count
    }
    
    func subscriptionMessageCount() -> Int {
        subscriptionMessages.count
    }
    
    func totalMessageCount() -> Int {
        messages.count + subscriptionMessages.count
    }
}
