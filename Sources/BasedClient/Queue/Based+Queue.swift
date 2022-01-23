//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 29/09/2021.
//

import Foundation

extension Based {
    
    func addToQueue(message: Message) {
        if let message = message as? SubscriptionMessage, message.requestType == .unsubscribe
            || message.requestType == .subscription
            || message.requestType == .sendSubscriptionData
            || message.requestType == .getSubscription {
            
//            queueManager.dispatch(item: { [weak self] in
//                self?.subscriptionQueue.append(message)
//            }, cancelable: false)
            subscriptionQueue.append(message)
            
        } else {
            
//            queueManager.dispatch(item: { [weak self] in
//                self?.queue.append(message)
//            }, cancelable: false)
            queue.append(message)
        }
        if socket.connected {
            drainQueue()
        }
    }
    
    func drainQueue() {
        guard socket.connected && (!queue.isEmpty || !subscriptionQueue.isEmpty) else { return }
        
        queueManager.dispatch(item: { [weak self] in
            guard let self = self else { return }
            
            let messages = (self.queue + self.subscriptionQueue).map { $0.codable }
            self.queue = []
            self.subscriptionQueue = []
            let json = try! JSONEncoder().encode(messages)
            
            if let jsonString = String(data: json, encoding: .utf8) {
                self.socket.send(message: .string(jsonString)) 
            }
//            self.socket.send(message: .data(json))
        }, cancelable: true)
        
    }
    
    func stopDrainQueue() {
        queueManager.cancelQueuedItems()
    }
    
    func removeFromQueue(type: RequestType) {
        subscriptionQueue.removeAll { message in
            message.requestType == type
        }
    }
}
