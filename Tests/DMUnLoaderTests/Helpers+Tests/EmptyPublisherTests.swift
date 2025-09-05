//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import Combine

final class EmptyPublisherTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: Initialization
    
    func testInitialization() {
        let publisher = EmptyPublisher()
        
        XCTAssertNotNil(publisher.notice,
                        "The notice property should be initialized")
    }
    
    // MARK: Behavior
    
    func testNoticeEmitsValue() {
        let publisher = EmptyPublisher()
        let expectation = XCTestExpectation(description: "Value received")
        var receivedValue: UInt?
        
        publisher.notice
            .sink { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let testValue: UInt = 42
        publisher.notice.send(testValue)
        
        wait(for: [expectation],
             timeout: 1.0)
        XCTAssertEqual(receivedValue,
                       testValue,
                       "The received value should match the sent value")
    }
    
    func testNoValuesEmittedWithoutSend() {
        let publisher = EmptyPublisher()
        let expectation = XCTestExpectation(description: "No value received")
        expectation.isInverted = true
        
        publisher.notice
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation],
             timeout: 0.01) // Expect no fulfillment within 0.1 seconds
    }
    
    func testMultipleSubscribersReceiveSameValue() {
        let publisher = EmptyPublisher()
        let expectation1 = XCTestExpectation(description: "Subscriber 1 received value")
        let expectation2 = XCTestExpectation(description: "Subscriber 2 received value")
        var receivedValue1: UInt?
        var receivedValue2: UInt?
        
        publisher.notice
            .sink { value in
                receivedValue1 = value
                expectation1.fulfill()
            }
            .store(in: &cancellables)
        
        publisher.notice
            .sink { value in
                receivedValue2 = value
                expectation2.fulfill()
            }
            .store(in: &cancellables)
        
        let testValue: UInt = 42
        publisher.notice.send(testValue)
        
        wait(for: [expectation1,
                   expectation2],
             timeout: 1.0)
        XCTAssertEqual(receivedValue1,
                       testValue,
                       "Subscriber 1 should receive the correct value")
        XCTAssertEqual(receivedValue2,
                       testValue,
                       "Subscriber 2 should receive the correct value")
    }
}
