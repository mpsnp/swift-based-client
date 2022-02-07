//
//  Based+Token.swift
//  
//
//  Created by Alexander van der Werff on 27/11/2021.
//

import Foundation
import AnyCodable


extension Based {
    func sendToken(_ token: String? = nil, _ options: SendTokenOptions? = nil) {
        beingAuth = true
        if let token = token {
            self.token = token
            self.sendTokenOptions = options
        } else {
            cache.forEach { args in
                let (id , _) = args
                if subscriptions[id] != nil {
                    cache.removeValue(forKey: id)
                }
            }
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
    
    func logoutSubscriptions(_ data: [Int]) {
        for id in data {
            cache.removeValue(forKey: id)
            var subscription = subscriptions[id]
            subscription?.error = BasedError.auth(token)
            
            subscription?.subscribers.forEach({ (id, callback) in
                callback.onError?(BasedError.auth(token))
            })
        }
    }
}

public struct SendTokenOptions {
    public let isBasedUser: Bool
    public init(isBasedUser: Bool) {
        self.isBasedUser = isBasedUser
    }
}
