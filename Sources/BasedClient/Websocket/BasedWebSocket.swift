//
//  BasedWebSocket.swift
//  
//
//  Created by Alexander van der Werff on 29/08/2021.
//

import Foundation

public final class BasedWebSocket {
    
    private let session: URLSession
    private var socket: URLSessionWebSocketTask?
    
    public init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    func connect(url: URL, time: Int = 0, reconnet: Bool = false) {
        self.socket = session.webSocketTask(with: url)
        self.listen()
        self.socket?.resume()
    }
    
    func listen() {
        self.socket?.receive { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
                return
            case .success(let message):
              switch message {
              case .data(let data):
                self.handle(data)
              case .string(let str):
                guard let data = str.data(using: .utf8) else { return }
                self.handle(data)
              @unknown default:
                break
              }
            }
        self.listen()
        }
    }
    
    func handle(_ data: Data) {
        print("joe")
    }
}
