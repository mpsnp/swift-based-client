//
//  MessagesTest.swift
//  
//
//  Created by Alexander van der Werff on 06/04/2022.
//

import Foundation
import XCTest

@testable import BasedClient

final class MessagesTest: XCTestCase {
    
    private var sut: Messages!
    
    override func setUp() {
        super.setUp()
        sut = Messages()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testUpdateSubscriptionMessages() async {
        let messageCount = 10
        for _ in 0..<messageCount {
            await sut.add(StubMessage.subscribeMessage())
        }
        let messages = await sut.allSubscriptionMessages()
        var m1 = messages.first!; m1.checksum = 1
        var m2 = messages.last!; m2.checksum = 2
        let modifyMessages = [
            m1, m2
        ]
        await sut.updateSubscriptionMessages(with: modifyMessages)
        let newMessages = await sut.allSubscriptionMessages()
        
        XCTAssertTrue(newMessages.count == messageCount, "Messages should be of lengtn \(messageCount)")
        
        let hasUpdatedMessage1 = newMessages.contains { message in
            message.checksum == 1
        }
        let hasUpdatedMessage2 = newMessages.contains { message in
            message.checksum == 2
        }
        
        XCTAssertTrue(hasUpdatedMessage1 && hasUpdatedMessage2, "New messages dhould contain updated messages")
    }
    
    func testDeleteSubscriptionMessages() async {
        let messageCount = 10
        var messages: [Message] = []
        for _ in 0..<messageCount {
            messages.append(StubMessage.subscribeMessage())
        }
        for message in messages {
            await sut.add(message)
        }
        let count = await sut.subscriptionMessageCount()
        XCTAssertEqual(count, messageCount, "Messages should be of lengtn \(messageCount)")
        
        await sut.removeSubscriptionMessages(with: messages)
        let deletedCount = await sut.subscriptionMessageCount()
        XCTAssertEqual(deletedCount, 0, "Messages should be of lengtn \(messageCount)")
    }
    
}
