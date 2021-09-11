import XCTest
@testable import BasedClient

final class EmitterTests: XCTestCase {
    
    private var sut: Emitter!
    
    override func setUp() {
        super.setUp()
        sut = Emitter()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testOnceEvent() {
        let expectation = self.expectation(description: "singe once event")
        
        sut.once("foo") { (arg: Int) in
            XCTAssertEqual(arg, 1, "Should be the emitted value")
            expectation.fulfill()
        }
        
        sut.emit(type: "foo", 1)
        
        waitForExpectations(timeout: 2) { error in
            print("Error: \(String(describing: error?.localizedDescription))")
        }
    }
    
    func testOnEvent() {
        let expectation = self.expectation(description: "singe on event")
        
        sut.on("foo") { (arg: Int) in
            XCTAssertEqual(arg, 1, "Should be the emitted value")
            expectation.fulfill()
        }
        
        sut.emit(type: "foo", 1)
        
        waitForExpectations(timeout: 2) { error in
            print("Error: \(String(describing: error?.localizedDescription))")
        }
    }
    
    func testOnNoArgumentsEvent() {
        let expectation = self.expectation(description: "singe on event and no arguments")
        
        sut.on("foo") {
            expectation.fulfill()
        }
        
        sut.emit(type: "foo")
        
        waitForExpectations(timeout: 2) { error in
            print("Error: \(String(describing: error?.localizedDescription))")
        }
    }
    
    func testOnceEventWithMultipleEmits() {
        let expectation = self.expectation(description: "singe once event")
        
        var onceCount = 0
        
        sut.once("foo") { (arg: Int) in
            XCTAssertEqual(arg, 1, "Should be the emitted value")
            onceCount += 1
        }
        
        sut.on("foo") { (arg: Int) in
            if arg == 3 && onceCount == 1 {
                expectation.fulfill()
            }
        }
        
        sut.emit(type: "foo", 1)
        sut.emit(type: "foo", 2)
        sut.emit(type: "foo", 3)
        
        waitForExpectations(timeout: 2) { error in
            print("Error: \(String(describing: error?.localizedDescription))")
        }
    }
    
}
