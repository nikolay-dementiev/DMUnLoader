//
//  File.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 19.02.2025.
//

import XCTest

/// This test chick the correctess of @WeakElements helper
final class WeaknesesOfObjects: XCTestCase {
    
    // MARK: Tests
    
    func testWeakRetainCycleReferences() {
        @WeakElements var cycleObjects = [StrongReferencesCycleObject]()
        
        let block = {
            let obj = StrongReferencesCycleObject()
            cycleObjects.append(obj)
        }
        block()
        
        XCTAssertEqual(cycleObjects.count,
                       1,
                       "StrongReferencesCycleObject should not be deallocated")
    }
    
    func testStrongRetainCycleReferences() {
        @WeakElements var cycleObjects = [WeakReferencesCycleObject]()
        
        let block = {
            let obj = WeakReferencesCycleObject()
            cycleObjects.append(obj)
        }
        block()
        
        XCTAssertEqual(cycleObjects.count,
                       0,
                       "WeakReferencesCycleObject should be deallocated")
    }
    
    // MARK: Mocks
    
    final class StrongReferencesCycleObject {
        var name: String = "Name"
        var closure: (() -> Void)?
        
        init() {
            self.closure = {
               _ = self.name
            }
        }
    }

    final class WeakReferencesCycleObject {
        var name: String = "Name"
        var closure: (() -> Void)?
        
        init() {
            self.closure = { [weak self] in
               _ = self?.name
            }
        }
    }
}
