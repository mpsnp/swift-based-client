//
//  SpyWebSocket.swift
//  
//
//  Created by Alexander van der Werff on 01/02/2022.
//

import Foundation
import Combine
@testable import BasedClient

class SpyWebSocket: WebSocket {
    var connected: Bool = false
    
    var invokedConnect = false
    var invokedConnectCount = 0
    var invokedConnectParameters: (url: URL, reconnect: Bool)?
    var invokedConnectParametersList = [(url: URL, reconnect: Bool)]()

    func connect(url: URL, reconnect: Bool) {
        invokedConnect = true
        invokedConnectCount += 1
        invokedConnectParameters = (url, reconnect)
        invokedConnectParametersList.append((url, reconnect))
    }

    var invokedDisconnect = false
    var invokedDisconnectCount = 0

    func disconnect() {
        invokedDisconnect = true
        invokedDisconnectCount += 1
    }

    var invokedSend = false
    var invokedSendCount = 0
    var invokedSendParameters: (message: URLSessionWebSocketTask.Message, Void)?
    var invokedSendParametersList = [(message: URLSessionWebSocketTask.Message, Void)]()
    var invokedSendCountSubject = PassthroughSubject<Int, Never>()

    func send(message: URLSessionWebSocketTask.Message) {
        invokedSend = true
        invokedSendCount += 1
        invokedSendParameters = (message, ())
        invokedSendParametersList.append((message, ()))
        invokedSendCountSubject.send(invokedSendCount)
    }

    var invokedIdleTimeout = false
    var invokedIdleTimeoutCount = 0

    func idleTimeout() {
        invokedIdleTimeout = true
        invokedIdleTimeoutCount += 1
    }
}
