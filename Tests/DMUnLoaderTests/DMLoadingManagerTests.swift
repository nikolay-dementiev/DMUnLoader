//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import Combine
@testable import DMUnLoader

final class DMLoadingManagerTests: XCTestCase {
        
    private var cancellables: Set<AnyCancellable> = []
    @WeakElements private var weakLoadingManager = [DMLoadingManager]()
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
        
        XCTAssertEqual(weakLoadingManager.count,
                       0,
                       "Loading manager should not be deallocated")
    }
    
    // Initialization
    @MainActor
    func testInitialization() {
        let settings = MockDMLoadingManagerSettings()
        let manager = DMLoadingManager(state: .none, settings: settings)
        weakLoadingManager.append(manager)
        
        // Ensure that the initial state is `.none`
        XCTAssertEqual(manager.loadableState,
                       .none,
                       "Initial loadableState should be .none")
    }
    
    // Test loading manager conforms to Hashable
    @MainActor
    func testDMLoadingManagerConformsToHashable() {
        let settings = MockDMLoadingManagerSettings()
        let manager = DMLoadingManager(state: .none, settings: settings)
        weakLoadingManager.append(manager)
        
        // Check if DMLoadingManager conforms to Hashable
        XCTAssertTrue((manager as Any) is (any Hashable), "DMLoadingManager should conform to Hashable")
    }
    
    // Test loading manager conforms to Identifiable
    @MainActor
    func testDMLoadingManagerConformsToIdentifiable() {
        let settings = MockDMLoadingManagerSettings()
        let manager = DMLoadingManager(state: .none, settings: settings)
        weakLoadingManager.append(manager)
        
        // Check if DMLoadingManager conforms to Identifiable
        XCTAssertTrue((manager as Any) is (any Identifiable), "DMLoadingManager should conform to Identifiable")
    }
    
    // Test loading manager conforms to ObservableObject
    @MainActor
    func testDMLoadingManagerConformsToObservableObject() {
        let settings = MockDMLoadingManagerSettings()
        let manager = DMLoadingManager(state: .none, settings: settings)
        weakLoadingManager.append(manager)
        
        // Check if DMLoadingManager conforms to ObservableObject
        XCTAssertTrue((manager as Any) is (any ObservableObject), "DMLoadingManager should conform to ObservableObject")
    }
    
    // Test loading manager instances conforms to Identifiable
    @MainActor
    func testDMLoadingManagerInstancesConformsToIdentifiable() {
        let settings = MockDMLoadingManagerSettings()
        
        // Create two DMLoadingManager instances
        let manager1 = DMLoadingManager(state: .none, settings: settings)
        let manager2 = DMLoadingManager(state: .none, settings: settings)
        
        weakLoadingManager.append(manager1)
        weakLoadingManager.append(manager2)
        
        // Verify that the IDs are unique
        XCTAssertNotEqual(manager1.id, manager2.id, "DMLoadingManager instances should have unique IDs")
    }
    
    // Test loading manager instances conforms to Hashable
    @MainActor
    func testDMLoadingManagerInstancesConformsToHashable() {
        let settings = MockDMLoadingManagerSettings()
        
        let newTheSameID = UUID()
        // Create two DMLoadingManager instances with the same ID
        let manager1 = DMLoadingManager(id: newTheSameID, state: .none, settings: settings)
        let manager2 = DMLoadingManager(id: newTheSameID, state: .none, settings: settings)
        
        weakLoadingManager.append(manager1)
        weakLoadingManager.append(manager2)
        
        // Verify equality
        XCTAssertEqual(manager1, manager2, "DMLoadingManager instances with the same ID should be equal")
        
        // Verify hashValue consistency
        var set = Set<DMLoadingManager>()
        set.insert(manager1)
        XCTAssertTrue(set.contains(manager2), "DMLoadingManager instances with the same ID should have the same hashValue")
    }
    
    // Show Loading State
    @MainActor
    func testShowLoading() throws {
        let expectation = XCTestExpectation(description: "Loadable state updated to .loading")
        
        let secondsAutoHideDelay: Double = 0.2
        let settings = MockDMLoadingManagerSettings(autoHideDelay: .seconds(secondsAutoHideDelay))
        let manager = DMLoadingManager(state: .none, settings: settings)
        weakLoadingManager.append(manager)
        
        // Observe changes to loadableState
        manager.$loadableState
            .dropFirst() // Skip the initial value
            .sink { state in
                XCTAssertEqual(state, .loading,
                               "loadableState should be updated to .loading")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Trigger the showLoading method
        manager.showLoading()
        
        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: secondsAutoHideDelay)
    }
    
    // Show Success State
    @MainActor
    func testShowSuccess() throws {
        let expectation = XCTestExpectation(description: "Loadable state updated to .success")
        
        let secondsAutoHideDelay: Double = 0.2
        let settings = MockDMLoadingManagerSettings(autoHideDelay: .seconds(secondsAutoHideDelay))
        let manager = DMLoadingManager(state: .none, settings: settings)
        weakLoadingManager.append(manager)
        
        // Observe changes to loadableState
        manager.$loadableState
            .dropFirst() // Skip the initial value
            .sink { state in
                if case .success(let message) = state {
                    XCTAssertEqual(message.description,
                                   "Test Message",
                                   "loadableState should be updated to .success with the correct message")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Trigger the showSuccess method
        manager.showSuccess("Test Message")
        
        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: secondsAutoHideDelay)
    }
    
    // Show Failure State
    @MainActor
    func testShowFailure() throws {
        let expectation = XCTestExpectation(description: "Loadable state updated to .failure")
        
        let secondsAutoHideDelay: Double = 0.2
        let settings = MockDMLoadingManagerSettings(autoHideDelay: .seconds(secondsAutoHideDelay))
        let manager = DMLoadingManager(state: .none, settings: settings)
        weakLoadingManager.append(manager)
        
        // Observe changes to loadableState
        manager.$loadableState
            .dropFirst() // Skip the initial value
            .sink { state in
                if case .failure(let error, _) = state {
                    XCTAssertEqual(error.localizedDescription,
                                   "Test Error",
                                   "loadableState should be updated to .failure with the correct error")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Trigger the showFailure method
        manager.showFailure(NSError(domain: "TestDomain",
                                    code: 1,
                                    userInfo: [NSLocalizedDescriptionKey: "Test Error"]))
        
        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: secondsAutoHideDelay)
    }
    
    // Test inactivity timer hides state early with hide expectation
    @MainActor
    func testInactivityTimerHidesStateEarlyHideExpectation() throws {
        let earlyHideExpectation = XCTestExpectation(description: "Loadable state should not hide earlier than 1.5 seconds")
        earlyHideExpectation.isInverted = true // This ensures the test fails if the expectation is fulfilled too early
        
        let secondsAutoHideDelay: Double = 0.05
        let settings = MockDMLoadingManagerSettings(autoHideDelay: .seconds(secondsAutoHideDelay))
        let manager = DMLoadingManager(state: .none, settings: settings)
        weakLoadingManager.append(manager)
        
        // Trigger the showSuccess method to start the inactivity timer
        manager.showSuccess("Test Message")
        
        // Check that the state does not transition to `.none` before `\(secondsAutoHideDelay)` seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsAutoHideDelay - 0.01) {
            // If the state has already transitioned to `.none`, log a failure (optional)
            XCTAssertFalse(manager.loadableState == .none,
                           "Loadable state transitioned to .none before the expected delay of `\(secondsAutoHideDelay)` seconds")
        }
        
        wait(for: [earlyHideExpectation], timeout: secondsAutoHideDelay + 0.01) // Ensure no early fulfillment
        XCTAssertTrue(manager.loadableState == .none,
                       "Loadable state didn't transitioned to .none the expected delay of `\(secondsAutoHideDelay)` seconds")
    }
    
    // Test inactivity timer hides state with hide expectation
    @MainActor
    func testInactivityTimerHidesStateHideExpectation() throws {
        let hideExpectation = XCTestExpectation(description: "Loadable state hidden after inactivity timer")
        
        let secondsAutoHideDelay: Double = 0.03
        let settings = MockDMLoadingManagerSettings(autoHideDelay: .seconds(secondsAutoHideDelay))
        let manager = DMLoadingManager(state: .none, settings: settings)
        weakLoadingManager.append(manager)
        
        // Observe changes to loadableState
        manager.$loadableState
            .dropFirst() // Skip the initial value
            .sink { state in
                if state == .none {
                    hideExpectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Trigger the showSuccess method to start the inactivity timer
        manager.showSuccess("Test Message")
        
        // Wait for the expectations to be fulfilled
        wait(for: [hideExpectation], timeout: secondsAutoHideDelay+0.1) // Ensure the state hides after the timer
    }
}
