//
//  MessageManager.swift
//  
//
//  Created by Alexander van der Werff on 01/02/2022.
//

import Foundation

actor MessageManager {
    private let messages: Messages
    private let socket: WebSocket
    private let encoder = JSONEncoder()
    private var activeTasks = [String: Task<(), Never>]()
    
    init(messages: Messages, socket: WebSocket) {
        self.messages = messages
        self.socket = socket
    }
    
    nonisolated func addMessage(_ message: Message) {
        Task { await messages.add(message) }
    }
    
    func sendAllMessages() {
        guard socket.connected else { return }
        let uuid = UUID().uuidString
        let task = Task {
            guard Task.isCancelled == false else { return }
            let messages = await messages.popAll().map { $0.codable }
            if let json = try? encoder.encode(messages),
                let jsonString = String(data: json, encoding: .utf8) {
                socket.send(message: .string(jsonString))
                socket.idleTimeout()
            }
            activeTasks[uuid] = nil
        }
        activeTasks[uuid] = task
    }
    
    func cancelAll() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
    
    func messageCount() async -> Int {
        await messages.messageCount()
    }
    
    func activityCount() async -> Int {
        activeTasks.count
    }
}
