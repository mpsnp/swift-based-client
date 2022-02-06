//
//  File.swift
//  
//
//  Created by Alexander van der Werff on 01/02/2022.
//

import Foundation
import Combine
import XCTest

@testable import BasedClient

final class MessageManagerTest: XCTestCase {
    
    private var sut: MessageManager!
    private var spyWebSocket: SpyWebSocket!
    private var anyCancellable: AnyCancellable?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        spyWebSocket = SpyWebSocket()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        spyWebSocket = nil
        try super.tearDownWithError()
    }
    
    func testAddingAndSendingMessages() async {
        let expectation = XCTestExpectation(description: "Send messages")
        spyWebSocket.connected = true
        let messages = Messages()
        sut = MessageManager(messages: messages, socket: spyWebSocket)
        sut.addMessage(StubMessage.random())
        sut.addMessage(StubMessage.random())
        await sut.sendAllMessages()
        sut.addMessage(StubMessage.random())
        anyCancellable = spyWebSocket.invokedSendCountSubject.first().sink(receiveValue: { [weak self] _ in
            guard let self = self else { return }
            XCTAssertEqual(self.spyWebSocket.invokedSendCount, 1, "One message should still be in the queue")
            Task {
                let count = await self.sut.messageCount()
                XCTAssertEqual(count, 1, "One message should be ready for sending")
                let activityCount = await self.sut.activityCount()
                XCTAssertEqual(activityCount, 0, "All tasks should be completed")
                expectation.fulfill()
            }
            
        })
        
        wait(for: [expectation], timeout: 2)
    }
    
}
