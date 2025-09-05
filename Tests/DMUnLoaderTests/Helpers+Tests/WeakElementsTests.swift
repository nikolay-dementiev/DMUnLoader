//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest

/// This test chick the correctess of @WeakElements helper
final class WeaknesesOfObjects: XCTestCase {
    
    // MARK: Tests
    
    func testWeakRetainCycleReferences() {
        @WeakElements var cycleObjects = [StrongReferencesCycleObjectClosureCycle]()
        
        let block = {
            let obj = StrongReferencesCycleObjectClosureCycle()
            cycleObjects.append(obj)
        }
        block()
        
        XCTAssertEqual(cycleObjects.count,
                       1,
                       "StrongReferencesCycleObject should not be deallocated")
    }
    
    func testStrongRetainCycleReferences() {
        @WeakElements var cycleObjects = [WeakReferencesCycleObjectClosureCycle]()
        
        let block = {
            let obj = WeakReferencesCycleObjectClosureCycle()
            cycleObjects.append(obj)
        }
        block()
        
        XCTAssertEqual(cycleObjects.count,
                       0,
                       "WeakReferencesCycleObject should be deallocated")
    }
    
    func testStrongRetainCycleReferencesForObjects() {
        
        @WeakElements var cycleObjects = [StrongReferencesCycleObjectCrossCycle]()
        
        let block = {
            // Creating objects retain cycle
            let firstObject = StrongReferencesCycleObjectCrossCycle()
            let secondObject = StrongReferencesCycleObjectCrossCycle()
            
            firstObject.strongReferenceObject = secondObject
            secondObject.strongReferenceObject = firstObject
            
            cycleObjects.append(firstObject)
            cycleObjects.append(secondObject)
        }
        block()
        
        XCTAssertEqual($cycleObjects.count,
                       2,
                       "StrongReferencesCycleObjectCrossCycle should not be deallocated")
    }
    
    func testWeakRetainCycleReferencesForObjects() {
        
        @WeakElements var cycleObjects = [WeakReferencesCycleObjectCrossCycle]()
        
        let block = {
            // Creating objects retain cycle
            let firstObject = WeakReferencesCycleObjectCrossCycle()
            let secondObject = WeakReferencesCycleObjectCrossCycle()
            
            firstObject.weakReferenceObject.append(secondObject)
            secondObject.weakReferenceObject.append(firstObject)
            
            cycleObjects.append(firstObject)
            cycleObjects.append(secondObject)
        }
        block()
        
        XCTAssertEqual(cycleObjects.count,
                       0,
                       "WeakReferencesCycleObject should be deallocated")
    }
    
    // MARK: Mocks
    
    final class StrongReferencesCycleObjectCrossCycle {
        var strongReferenceObject: StrongReferencesCycleObjectCrossCycle?
    }
    
    final class WeakReferencesCycleObjectCrossCycle {
        @WeakElements var weakReferenceObject = [WeakReferencesCycleObjectCrossCycle?]()
    }
    
    final class StrongReferencesCycleObjectClosureCycle {
        var name: String = "Name"
        var closure: (() -> Void)?
        
        init() {
            self.closure = {
               _ = self.name
            }
        }
    }

    final class WeakReferencesCycleObjectClosureCycle {
        var name: String = "Name"
        var closure: (() -> Void)?
        
        init() {
            self.closure = { [weak self] in
               _ = self?.name
            }
        }
    }
}
