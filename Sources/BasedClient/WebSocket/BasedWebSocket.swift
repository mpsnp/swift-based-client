//
//  BasedWebSocket.swift
//  
//
//  Created by Alexander van der Werff on 29/08/2021.
//

import Foundation

protocol BasedWebSocketDelegate: AnyObject {
    func onError(_: Error?)
    func onData(data: URLSessionWebSocketTask.Message)
    func onOpen()
    func onReconnect()
    func onClose()
}

protocol WebSocket {
    func connect(url: URL, reconnect: Bool)
    func disconnect()
    func send(message: URLSessionWebSocketTask.Message)
    func idleTimeout()
    var connected: Bool { get set }
}

final class BasedWebSocket: NSObject, WebSocket {
    
    weak var delegate: BasedWebSocketDelegate?
    
    private var session: URLSession!
    private var socket: URLSessionWebSocketTask?
    private var reconnecting: Bool = false
    private var url: URL?
    private var timer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "based.socker.timer", qos: .background)
    
    public var connected = false
    
    override init() {
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
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
        self.socket = nil
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.connect(url: url, reconnect: true)
        }
    }
    
    func disconnect() {
        socket?.cancel(with: .goingAway, reason: nil)
        socket = nil
    }
    
    // request type, subscription is, payload/query,checksum, request variant, custom observable func
    //[[1,138599703,{"id":"drc028ed00","documents":true},0,0,"drones-observeId"]]
    func send(message: URLSessionWebSocketTask.Message) {
        socket?.send(message, completionHandler: { [weak self] error in
            dataInfo(error?.localizedDescription ?? "")
            switch (error as NSError?)?.code {
            case .some(54), .some(57): self?.reconnect()
            default: break
            }
        })
    }
    
    //
    private func listen() {
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
            reconnecting = false
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
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        delegate?.onError(error)
        reconnect()
    }
    
}

extension BasedWebSocket {
    func idleTimeout() {
        timer?.cancel()
        timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer?.schedule(deadline: .now() + .milliseconds(Int(60 * 1e3)))
        timer?.setEventHandler(handler: { [weak self] in
            self?.send(message: .string("1"))
            self?.idleTimeout()
        })
        timer?.activate()
    }
}
