//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader

final class AtomicTests: XCTestCase {
    
    @WeakElements private var weakAtomicNSNumber = [Atomic<NSNumber>]()
    @WeakElements private var weakAtomicInt = [Atomic<Int>]()
    @WeakElements private var weakAtomicIntArray = [Atomic<[Int]>]()
    @WeakElements private var weakAtomicSendableStruct = [Atomic<SendableStruct>]()
    @WeakElements private var weakAtomicString = [Atomic<String>]()
    @WeakElements private var weakAtomicDouble = [Atomic<Double>]()
    
    override func tearDown() {
        super.tearDown()
        
        XCTAssertEqual(self.weakAtomicNSNumber.count,
                       0,
                       "The weak reference count for type `Atomic<NSNumber>` should be 0.")
        XCTAssertEqual(self.weakAtomicInt.count,
                       0,
                       "The weak reference count for type `Atomic<Int>` should be 0.")
        XCTAssertEqual(self.weakAtomicIntArray.count,
                       0,
                       "The weak reference count for type `Atomic<[Int]>` should be 0.")
        XCTAssertEqual(self.weakAtomicSendableStruct.count,
                       0,
                       "The weak referenc count for type `Atomic<SendableStruct>` should be 0.")
        XCTAssertEqual(self.weakAtomicString.count,
                       0,
                       "The weak reference count for type`Atomic<String>` should be 0.")
        XCTAssertEqual(self.weakAtomicDouble.count,
                       0,
                       "The weak reference count for type `Atomic<Double>` should be 0.")
    }
    
    // MARK: Initialization
    
    func testInitialization() {
        let atomic = Atomic<Int>(42)
        weakAtomicInt.append(atomic)
        
        XCTAssertEqual(atomic.wrappedValue,
                       42,
                       "The initial value should match the provided value")
    }
    
    // MARK: Thread Safety
    
    func testConcurrentAccess() {
        let atomic = Atomic<Int>(0)
        weakAtomicInt.append(atomic)
        let iterations = 10_000
        let queue = DispatchQueue(label: "concurrent.queue",
                                  attributes: .concurrent)
        let group = DispatchGroup()
        
        for _ in 0..<iterations {
            queue.async(group: group) {
                atomic.mutate { prop in
                    prop += 1
                }
            }
        }
        
        group.wait()
        
        XCTAssertEqual(atomic.wrappedValue,
                       iterations,
                       "The final value should match the number of increments")
    }
    
    func testConcurrentAccessForChangeViaMutateFunc() {
        let atomic = Atomic<NSNumber>(0)
        weakAtomicNSNumber.append(atomic)
        
        let iterations = 10_000
        let queue = DispatchQueue(label: "concurrent.queue",
                                  attributes: .concurrent)
        let group = DispatchGroup()
        
        for _ in 0..<iterations {
            queue.async(group: group) {
                atomic.mutate { prop in
                    // swiftlint:disable:next compiler_protocol_init
                    prop = NSNumber(integerLiteral: prop.intValue + 1)
                }
            }
        }
        
        group.wait()
        
        XCTAssertEqual(atomic.wrappedValue.intValue,
                       iterations,
                       "The final value should match the number of increments")
    }
    
    func testConcurrentAccessForChangeViaWrappedValue() {
        
        let group = DispatchGroup()
        
        let block = { [weak self] in
            let atomic = Atomic<NSNumber>(0)
            self?.weakAtomicNSNumber.append(atomic)
            
            let queue = DispatchQueue(label: "concurrent.queue",
                                      attributes: .concurrent)
            
            let iterations = 10
            for _ in 0..<iterations {
                queue.async(group: group) {
                    // swiftlint:disable:next compiler_protocol_init
                    atomic.wrappedValue = NSNumber(integerLiteral: atomic.wrappedValue.intValue + 1)
                }
            }
        }
        
        block()
        
        let waitingResult = group.wait(timeout: .now() + 1)
        XCTAssertEqual(waitingResult,
                       .success,
                       "testConcurrentAccessForChangeViaWrappedValue: `group.wait()` should complete in `1`!")
        
        XCTAssertEqual(weakAtomicNSNumber.count,
                       0,
                       """
                       The weak reference count for type `Atomic<NSNumber>` in
                       `testConcurrentAccessForChangeViaWrappedValue` should be 0.
                       """)
    }
    
    // MARK: Mutation Behavior
    
    func testWrappedValueSetterClosureBehavior() {
        let atomic = Atomic<Int>(0)
        weakAtomicInt.append(atomic)
        
        // Simulate setting a new value using the setter
        let newValue = 42
        let expectation = XCTestExpectation(description: "Value updated")
        
        DispatchQueue.global(qos: .userInitiated).async {
            atomic.wrappedValue = newValue
            expectation.fulfill()
        }
        
        wait(for: [expectation],
             timeout: 0.1)
        
        XCTAssertEqual(atomic.wrappedValue,
                       newValue,
                       "The wrappedValue should be updated to the new value")
    }
    
    func testMutate() {
        let atomic = Atomic<[Int]>([])
        weakAtomicIntArray.append(atomic)
        
        atomic.mutate { array in
            array.append(1)
            array.append(2)
        }
        
        XCTAssertEqual(atomic.wrappedValue,
                       [1,
                        2],
                       "The mutation should modify the value correctly")
    }
    
    func testMutateWithNoChange() {
        let atomic = Atomic<Int>(42)
        weakAtomicInt.append(atomic)
        
        atomic.mutate { value in
            // No changes to the value
        }
        
        XCTAssertEqual(atomic.wrappedValue,
                       42,
                       "The value should remain unchanged if no mutation occurs")
    }
    
    // MARK: Projected Value
    
    func testProjectedValue() {
        let atomic = Atomic<String>("Hello")
        weakAtomicString.append(atomic)
        
        XCTAssertTrue(atomic.projectedValue === atomic,
                      "The projected value should be the same instance as the Atomic wrapper")
    }
    
    // MARK: Call As Function
    
    func testCallAsFunction() {
        let atomic = Atomic<Double>(3.14)
        weakAtomicDouble.append(atomic)
        
        XCTAssertEqual(atomic(),
                       3.14,
                       "The callAsFunction method should return the wrapped value")
    }
    
    // MARK: Sendable Compliance
    
    func testSendableCompliance() {
        let atomic = Atomic<SendableStruct>(SendableStruct(value: 42))
        weakAtomicSendableStruct.append(atomic)
        
        XCTAssertNoThrow({
            let _: SendableStruct = atomic.wrappedValue
        },
                         "The ValueType should comply with Sendable")
    }
    
    private struct SendableStruct: Sendable {
        var value: Int
    }
}
