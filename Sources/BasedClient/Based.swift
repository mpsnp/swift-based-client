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
    
    private let basedWebSocket: BasedWebSocket
    
    private var connection: Connection?
    
    public required init(config: BasedConfig, ws: BasedWebSocket = BasedWebSocket()) {
        defer {
            connect(with: config.url)
        }
        basedWebSocket = ws
    }
    
    func connect(with url: String) {
        self.connection = connectWebsocket(url)
    }
    
//    public connect(url: string | (() => Promise<string>)) {
//      this.client.connection = connectWebsocket(this.client, url)
//    }
//
//    public disconnect() {
//      if (this.client.connection) {
//        this.client.connection.disconnected = true
//        if (this.client.connection.ws) {
//          this.client.connection.ws.close()
//        }
//        if (this.client.connected) {
//          this.client.onClose()
//        }
//        delete this.client.connection
//      }
//      this.client.connected = false
//    }
}

extension Based {
    func connectWebsocket(_ url: String) -> Connection? {
        guard let url = URL(string: url) else { return nil }
        basedWebSocket.connect(url: url)
        return nil
    }
}
