//
//  Based+Messages.swift
//  
//
//  Created by Alexander van der Werff on 29/09/2021.
//

import Foundation

extension Based {
    
    func addToMessages(_ message: Message) {
        
        Task { await messages.add(message) }

        if socket.connected {
            Task { await messageManager.sendAllMessages() }
        }
    }
    
}
