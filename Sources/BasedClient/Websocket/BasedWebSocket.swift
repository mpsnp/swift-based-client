//
//  BasedWebSocket.swift
//  
//
//  Created by Alexander van der Werff on 29/08/2021.
//

import Foundation

protocol BasedWebSocketDelegate: AnyObject {
    func onError(_: Error)
    func onData(data: URLSessionWebSocketTask.Message)
    func onOpen()
    func onReconnect()
    func onClose()
}

final class BasedWebSocket: NSObject {
    
    weak var delegate: BasedWebSocketDelegate?
    
    private let session: URLSession
    private var socket: URLSessionWebSocketTask?
    private var reconnecting: Bool = false
    private var url: URL?
    private var timer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "based.socker.timer", qos: .background)
    
    
    public var connected = false {
        didSet {
            
        }
    }
    
    init(session: URLSession = URLSession(configuration: .default)) {
        self.session = session
    }
    
    func connect(url: URL, reconnect: Bool = false) {
        self.socket = session.webSocketTask(with: url)
        self.listen()
        self.reconnecting = reconnect
        self.url = url
        self.socket?.resume()
    }
    
    private func reconnect() {
        guard let url = url else { return }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.connect(url: url, reconnect: true)
        }
    }
    
    func disconnect() {
        socket?.cancel(with: .goingAway, reason: nil)
    }
    
    func send(message: URLSessionWebSocketTask.Message) {
        socket?.send(message, completionHandler: { error in
            
        })
    }
    
    //
    func listen() {
        socket?.receive { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.delegate?.onError(error)
            case .success(let message):
                self.delegate?.onData(data: message)
            }
            self.listen()
        }
    }
    
}

extension BasedWebSocket: URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        connected = true
        if reconnecting {
            delegate?.onReconnect()
        }
        delegate?.onOpen()
    }
    
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?) {
            connected = false
            delegate?.onClose()
            switch closeCode {
            case .goingAway:
                reconnecting = false
                break
            default: reconnect()
        }
    }
    
}

extension BasedWebSocket {
    func idleTimeout() {
        timer?.cancel()
        timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer?.schedule(deadline: .now() + .milliseconds(Int(60 * 1e3)))
        timer?.setEventHandler(handler: { [weak self] in
            self?.send(message: .string("1"))
        })
        timer?.activate()
    }
}
