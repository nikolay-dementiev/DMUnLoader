//
//  DMLoadingManagerTests.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 13.02.2025.
//

import XCTest
import Combine
@testable import DMErrorHandling

final class DMLoadingManagerTests: XCTestCase {
        
    var cancellables: Set<AnyCancellable> = []
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    // Test 1: Initialization
    @MainActor
    func testInitialization() {
        let settings = MockDMLoadingManagerSettings()
        let manager = DMLoadingManager(state: .none, settings: settings)
        
        // Ensure that the initial state is `.none`
        XCTAssertEqual(manager.loadableState,
                       .none,
                       "Initial loadableState should be .none")
    }
    
    // Test 2: Show Loading State
    @MainActor
    func testShowLoading() throws {
        let expectation = XCTestExpectation(description: "Loadable state updated to .loading")
        
        let settings = MockDMLoadingManagerSettings()
        let manager = DMLoadingManager(state: .none, settings: settings)
        
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
        wait(for: [expectation], timeout: 0.2)
    }
    
    // Test 3: Show Success State
    @MainActor
    func testShowSuccess() throws {
        let expectation = XCTestExpectation(description: "Loadable state updated to .success")
        
        let settings = MockDMLoadingManagerSettings(autoHideDelay: .seconds(0.5))
        let manager = DMLoadingManager(state: .none, settings: settings)
        
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
        wait(for: [expectation], timeout: 0.2)
    }
    
    // Test 4: Show Failure State
    @MainActor
    func testShowFailure() throws {
        let expectation = XCTestExpectation(description: "Loadable state updated to .failure")
        
        let settings = MockDMLoadingManagerSettings(autoHideDelay: .seconds(0.5))
        let manager = DMLoadingManager(state: .none, settings: settings)
        
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
        wait(for: [expectation], timeout: 0.2)
    }
    
    // Test 5: Inactivity Timer Hides State
    @MainActor
    func testInactivityTimerHidesState() throws {
        let expectation = XCTestExpectation(description: "Loadable state hidden after inactivity timer")
        
        let settings = MockDMLoadingManagerSettings(autoHideDelay: .seconds(0.2))
        let manager = DMLoadingManager(state: .none, settings: settings)
        
        // Observe changes to loadableState
        manager.$loadableState
            .dropFirst() // Skip the initial value
            .sink { state in
                if state == .none {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Trigger the showSuccess method to start the inactivity timer
        manager.showSuccess("Test Message")
        
        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 0.2)
    }
    
    // Test 6: Stop Timer and Hide
    @MainActor
    func testStopTimerAndHide() throws {
        let expectation = XCTestExpectation(description: "Loadable state hidden after stopping timer")
        
        let settings = MockDMLoadingManagerSettings(autoHideDelay: .seconds(0.5))
        let manager = DMLoadingManager(state: .none, settings: settings)
        
        // Observe changes to loadableState
        manager.$loadableState
            .dropFirst() // Skip the initial value
            .sink { state in
                if state == .none {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Trigger the showSuccess method to start the inactivity timer
        manager.showSuccess("Test Message")
        
        // Stop the timer and hide manually
        manager.stopTimerAndHide()
        
        // Wait for the expectation to be fulfilled
        wait(for: [expectation], timeout: 0.2)
    }
}
