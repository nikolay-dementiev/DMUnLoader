//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader

final class DispatchQueueOnceTests: XCTestCase {
    
    // MARK: - Test Setup
    
    override func tearDown() {
        super.tearDown()
        // Reset trackers after each test to avoid side effects
        DispatchQueue.resetTrackersSet()
    }
    
    // MARK: - Test `once(token:)`
    
    func testOnceTokenExecutesBlockOnlyOnce() {
        let token = "com.example.testToken"
        var executionCount = 0
        
        (0..<20).forEach { _ in
            DispatchQueue.once(token: token) {
                executionCount += 1
            }
        }
        
        XCTAssertEqual(executionCount, 1, "Block should execute once")
        
        // Call again with the same token
        DispatchQueue.once(token: token) {
            executionCount += 1
        }
        
        XCTAssertEqual(executionCount, 1, "Block should not execute again with the same token")
    }
    
    func testOnceTokenWithDifferentTokens() {
        let token1 = "com.example.testToken1"
        let token2 = "com.example.testToken2"
        var executionCount1 = 0
        var executionCount2 = 0
        
        (0..<20).forEach { _ in
            DispatchQueue.once(token: token1) {
                executionCount1 += 1
            }
            DispatchQueue.once(token: token2) {
                executionCount2 += 1
            }
        }
        
        XCTAssertEqual(executionCount1, 1, "Block for token1 should execute once")
        XCTAssertEqual(executionCount2, 1, "Block for token2 should execute once")
    }
    
    // MARK: - Test `once(forObject:)`
    
    func testOnceForObjectExecutesBlockOnlyOnce() {
        let object = NSObject()
        var executionCount = 0
        
        (0..<20).forEach { _ in
            DispatchQueue.once(forObject: object,
                               position: .any) {
                executionCount += 1
            }
        }
        
        XCTAssertEqual(executionCount, 1, "Block should execute once for the object")
        
        // Call again with the same object
        (0..<20).forEach { _ in
            DispatchQueue.once(forObject: object,
                               position: .any) {
                executionCount += 1
            }
        }
        
        XCTAssertEqual(executionCount, 1, "Block should not execute again for the same object")
    }
    
    func testOnceForObjectWithDifferentObjects() {
        let object1 = NSObject()
        let object2 = NSObject()
        var executionCount1 = 0
        var executionCount2 = 0
        
        (0..<20).forEach { _ in
            DispatchQueue.once(forObject: object1) {
                executionCount1 += 1
            }
            DispatchQueue.once(forObject: object2,
                               position: .current) {
                executionCount2 += 1
            }
        }
        
        XCTAssertEqual(executionCount1, 1, "Block should execute once for object1")
        XCTAssertEqual(executionCount2, 1, "Block should execute once for object2")
    }
    
    func testOnceForNilObjectExecutesBlockOnlyOnce() {
        let object: NSObject? = nil
        var executionCount = 0
        
        (0..<20).forEach { _ in
            DispatchQueue.once(forObject: object,
                               position: .any) {
                executionCount += 1
            }
        }
        
        XCTAssertEqual(executionCount, 1, "Block should execute once for the object")
        
        // Call again with the same object
        (0..<20).forEach { _ in
            DispatchQueue.once(forObject: object,
                               position: .any) {
                executionCount += 1
            }
        }
        
        XCTAssertEqual(executionCount, 1, "Block should not execute again for the same object")
    }
    
    // MARK: - Test `once(forObjects:)`
    
    func testOnceForObjectsExecutesBlockOnlyOnce() {
        let object1 = NSObject()
        let object2 = NSObject()
        var executionCount = 0
        
        (0..<20).forEach { _ in
            DispatchQueue.once(forObjects: [object1, object2],
                               position: .any) {
                executionCount += 1
            }
        }
        
        XCTAssertEqual(executionCount, 1, "Block should execute once for the objects")
        
        // Call again with the same objects
        (0..<20).forEach { _ in
            DispatchQueue.once(forObjects: [object1, object2],
                               position: .any) {
                executionCount += 1
            }
        }
        
        XCTAssertEqual(executionCount, 1, "Block should not execute again for the same objects")
    }
    
    func testOnceForObjectsWithDifferentObjectSets() {
        let object1 = NSObject()
        let object2 = NSObject()
        let object3 = NSObject()
        var executionCount1 = 0
        var executionCount2 = 0
        
        (0..<20).forEach { _ in
            DispatchQueue.once(forObjects: [object1, object2],
                               position: .current) {
                executionCount1 += 1
            }
            DispatchQueue.once(forObjects: [object2, object3],
                               position: .current) {
                executionCount2 += 1
            }
        }
        XCTAssertEqual(executionCount1, 1, "Block should execute once for [object1, object2]")
        XCTAssertEqual(executionCount2, 1, "Block should execute once for [object2, object3]")
    }
    
    func testOnceForNIlObjectsExecutesBlockOnlyOnce() {
        var executionCount = 0
        
        (0..<20).forEach { _ in
            DispatchQueue.once(forObjects: nil,
                               position: .any) {
                executionCount += 1
            }
        }
        
        XCTAssertEqual(executionCount, 1, "Block should execute once for the objects")
        
        // Call again with the same objects
        (0..<20).forEach { _ in
            DispatchQueue.once(forObjects: nil,
                               position: .any) {
                executionCount += 1
            }
        }
        
        XCTAssertEqual(executionCount, 1, "Block should not execute again for the same objects")
    }
    
    // MARK: - Test `ObjectPosition`
    
    func testOnceForObjectPositionCurrent() {
        let object = NSObject()
        var executionCount = 0
        
        (0..<20).forEach { _ in
            DispatchQueue.once(forObject: object,
                               position: .current) {
                executionCount += 1
            }
        }
        
        XCTAssertEqual(executionCount, 1, "Block should execute once for the object with .specific position")
        
        // Call again with the same object and position
        (0..<20).forEach { _ in
            DispatchQueue.once(forObject: object,
                               position: .current) {
                executionCount += 1
            }
        }
        
        XCTAssertEqual(executionCount, 2, "Block should not execute again for the same object with .specific position")
    }
    
    func testOnceForObjectPositionAny() {
        let object1 = NSObject()
        let object2 = NSObject()
        var executionCountObject1 = 0
        var executionCountObject2 = 0
        
        DispatchQueue.once(forObject: object1,
                           position: .any) {
            executionCountObject1 += 1
        }
        DispatchQueue.once(forObject: object1,
                           position: .any) {
            executionCountObject1 += 1
        }
        
        XCTAssertEqual(executionCountObject1, 1, "Block should execute once for object1 with .any position")
        
        // Call again with a different object and .any position
        DispatchQueue.once(forObject: object2,
                           position: .any) {
            executionCountObject2 += 1
        }
        DispatchQueue.once(forObject: object2,
                           position: .any) {
            executionCountObject2 += 1
        }
        
        XCTAssertEqual(executionCountObject2, 1, "Block should not execute again for a different object with .any position")
    }
    
    // MARK: - Test `resetTrackersSet()`
    
    func testResetTrackersSet() {
        let token = "com.example.testToken"
        var executionCount = 0
        
        DispatchQueue.once(token: token) {
            executionCount += 1
        }
        
        XCTAssertEqual(executionCount, 1, "Block should execute once")
        
        // Reset trackers
        DispatchQueue.resetTrackersSet()
        
        // Call again with the same token
        DispatchQueue.once(token: token) {
            executionCount += 1
        }
        
        XCTAssertEqual(executionCount, 2, "Block should execute again after resetting trackers")
    }
    
    // MARK: - Multithreading Tests
    
    func testOnceTokenIsThreadSafe() {
        let token = "com.example.threadSafeToken"
        let queue = DispatchQueue(label: "concurrent", attributes: .concurrent)
        let group = DispatchGroup()
        
        let executionCountMock = MockOnceTokenObject()
        
        for _ in 0..<20 {
            queue.async(group: group) { [executionCountMock] in
                DispatchQueue.once(token: token) { [executionCountMock] in
                    executionCountMock.executionCount += 1
                }
            }
        }
        
        group.wait()
        XCTAssertEqual(executionCountMock.executionCount, 1, "Block should execute exactly once in a multithreaded environment")
    }
    
    final class MockOnceTokenObject: @unchecked Sendable {
        var executionCount = 0
    }
}
