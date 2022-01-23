//
//  Based.swift
//  
//
//  Created by Alexander van der Werff on 29/08/2021.
//

import Foundation
import AnyCodable


public final class Based {
    
    var config: BasedConfig
    
    let decoder = JSONDecoder()
    
    let encoder = JSONEncoder()
    
    let emitter: Emitter
    
    let socket: BasedWebSocket
    
    var subscriptions = Subscriptions()
    
    var cache: [Int: (value: Data, checksum: Int)] = [:]
    
    var token: String?
    
    var beingAuth = false
    
    var sendTokenOptions: SendTokenOptions?
    
    var subscriptionQueue = [SubscriptionMessage]()
    
    var queue = [Message]()
    
    let queueManager = QueueManager()
    
    var auth: [AuthFunction] = []
    
    typealias RequestId = Int
    typealias RequestCallbacks = Dictionary<RequestId, RequestCallback>
    var requestIdCnt: Int = 0
    var requestCallbacks = RequestCallbacks()
    
    public required convenience init(config: BasedConfig) {
        self.init(config: config, ws: BasedWebSocket(), emitter: Emitter())
    }
    
    internal init(
        config: BasedConfig,
        ws: BasedWebSocket,
        emitter: Emitter
    ) {
        self.config = config
        self.socket = ws
        self.emitter = emitter
        self.socket.delegate = self
        Task.init {
            do {
                try await connect(with: config.url)
            }
            catch { print(error) }
        }
    }
    
    deinit {
        self.socket.disconnect()
    }
    
    public func connect(with url: URL) {
        socket.connect(url: url)
    }

    public func disconnect() {
        guard socket.connected else { return }
        socket.disconnect()
        onClose()
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
        sendToken(token, sendTokenOptions)
        sendAllSubscriptions()
        drainQueue()
    }
    
    func onError(_: Error) {
        
    }
    
    func onData(data: URLSessionWebSocketTask.Message) {
        switch data {
        case .string(let json):
            guard
                let jsonData = json.data(using: .utf8),
                let dataMessage = try? decoder.decode([AnyCodable].self, from: jsonData)
            else { return }
            
            switch RequestType(rawValue: dataMessage[0].value as? Int ?? -1) {
            case .some(.token):
                if let data = dataMessage[1].value as? [Int], dataMessage.count > 1 {
                    logoutSubscriptions(data)
                }
                if let state = dataMessage[2].value as? Bool {
                    auth.forEach { auth in
                        auth.resolve(!state)
                    }
                }
                beingAuth = false
                auth = []
            case .some(.set), .some(.get), .some(.configuration), .some(.getConfiguration), .some(.call), .some(.delete), .some(.copy), .some(.digest):
                incomingRequest(dataMessage)
            case .some(.subscription):
                //ex: [1,-1725702994954,{\"$isNull\":true},3391353116945]
                if
                    let id = dataMessage[1].value as? Int,
                    let checksum = dataMessage[3].value as? Int,
                    let jsonData = try? encoder.encode(dataMessage[2]) {
                        
                    var error: ErrorObject?
                    if dataMessage.count > 4 {
                        error = .init(from: dataMessage[4])
                    }
                    
                    incomingSubscription(SubscriptionData(id: id, data: jsonData, checksum: checksum, error: error))
                }
            case .some(.subscriptionDiff):
                if
                    let id = dataMessage[1].value as? Int,
                    let diff = try? JSON(dataMessage[2].value),
                    let checksums = dataMessage[3].value as? [Int], checksums.count > 1 {
                    
                    let previous = checksums[0]
                    let current = checksums[1]
                    
                    incomingSubscriptionDiff(SubscriptionDiffData(id: id, patchObject: diff, checksums: (previous: previous, current: current)))
                }
            default:
                print("no match")
            }
            
        default: break
        }
    }
    
}
