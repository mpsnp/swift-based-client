//
//  Based.swift
//  
//
//  Created by Alexander van der Werff on 29/08/2021.
//

import Foundation

public struct BasedConfig {
    public let url: String
    public init(url: String) {
        self.url = url
    }
}

public final class Based {
    
    let socket: BasedWebSocket
    
    private let emitter: Emitter
    
    var subscriptions = Subscriptions()
    
    var cache: [UInt64: (value: JSON, checksum: UInt64)] = [:]
    
    private var token: String?
    
    private var beingAuth = false
    
    var subscriptionQueue = [Message]()
    
    var queue = [Message]()
    
    let queueManager = QueueManager()
    
    
    public required convenience init(config: BasedConfig) {
        defer {
            connect(with: config.url)
        }
        self.init()
    }
    
    internal init(
        ws: BasedWebSocket = BasedWebSocket(),
        emitter: Emitter = Emitter()
    ) {
        self.socket = ws
        self.emitter = emitter
        self.socket.delegate = self
    }
    
    public func connect(with url: String) {
        guard let url = URL(string: url) else { return }
        socket.connect(url: url)
    }

    public func disconnect() {
        guard socket.connected else { return }
        socket.disconnect()
        onClose()
    }
}

extension Based {
    func sendToken(token: String?) {
        beingAuth = true
        if let token = token {
            self.token = token
        } else {
            cache.forEach { args in
                let (id , _) = args
                if subscriptions[id] != nil {
                    cache.removeValue(forKey: id)
                }
            }
            self.token = nil
        }
        if socket.connected {
            let jsonData = try! JSONEncoder().encode(token != nil ? ["\(RequestType.token)", token] : ["\(RequestType.token)"])
            socket.send(message: .data(jsonData))
            socket.idleTimeout()
            sendAllSubscriptions(reAuth: true)
        }
    }
}

extension Based: BasedWebSocketDelegate {
    
    func onClose() {
        stopDrainQueue()
        removeFromQueue(type: .unsubscribe)
        removeFromQueue(type: .sendSubscriptionData)
        emitter.emit(type: "disconnect")
    }
    
    func onReconnect() {
        emitter.emit(type: "reconnect")
    }
    
    func onOpen() {
        emitter.emit(type: "connect")
        sendToken(token: token)
//        sendAllSubscriptions(this)
    }
    
    func onError(_: Error) {
        
    }
    
    func onData(data: URLSessionWebSocketTask.Message) {
        
    }
    
}


extension Based {
    
    func stopDrainQueue() {

    }
    
    func removeFromQueue(type: RequestType) {
        subscriptionQueue.removeAll { message in
            message.requestType == type
        }
    }
    
}
