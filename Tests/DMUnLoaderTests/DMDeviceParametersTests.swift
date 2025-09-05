//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader

final class DMDeviceParametersTests: XCTestCase {
    
    // MARK: - Tests for Default Behavior
    
    @MainActor
    func testDefaultScreenSizeProvider() {
        // Reset to the default screen size provider
        DMNativeDeviceParameters.resetScreenSizeProvider()
        
        // Access the device screen size
        let screenSize = DMNativeDeviceParameters.deviceScreenSize
        
        // Assert that the screen size is valid (greater than zero)
        XCTAssertGreaterThan(screenSize.width,
                             0,
                             "Width should be greater than zero")
        XCTAssertGreaterThan(screenSize.height,
                             0,
                             "Height should be greater than zero")
    }
    
    // MARK: - Tests for Custom Screen Size Provider
    
    @MainActor
    func testCustomScreenSizeProvider() {
        // Create a mock screen size provider
        struct MockScreenSizeProvider: ScreenSizeProvider {
            func getScreenSize() -> CGSize {
                return CGSize(width: 414,
                              height: 896) // Simulated iPhone 11 Pro Max screen size
            }
        }
        
        // Inject the mock provider
        DMNativeDeviceParameters.screenSizeProvider = MockScreenSizeProvider()
        
        // Access the device screen size
        let screenSize = DMNativeDeviceParameters.deviceScreenSize
        
        // Assert that the screen size matches the mocked value
        XCTAssertEqual(screenSize.width,
                       414,
                       "Width should match the mocked screen size")
        XCTAssertEqual(screenSize.height,
                       896,
                       "Height should match the mocked screen size")
    }
    
    // MARK: - Tests for Reset Functionality
    
    @MainActor
    func testResetScreenSizeProvider() {
        // Inject a custom screen size provider
        struct MockScreenSizeProvider: ScreenSizeProvider {
            func getScreenSize() -> CGSize {
                return CGSize(width: 100,
                              height: 200)
            }
        }
        DMNativeDeviceParameters.screenSizeProvider = MockScreenSizeProvider()
        
        // Reset the provider to the default implementation
        DMNativeDeviceParameters.resetScreenSizeProvider()
        
        // Access the device screen size after reset
        let screenSize = DMNativeDeviceParameters.deviceScreenSize
        
        // Assert that the screen size is no longer the custom size
        XCTAssertNotEqual(screenSize.width,
                          100,
                          "Width should not match the custom screen size after reset")
        XCTAssertNotEqual(screenSize.height,
                          200,
                          "Height should not match the custom screen size after reset")
        
        // Assert that the screen size is valid (greater than zero)
        XCTAssertGreaterThan(screenSize.width,
                             0,
                             "Width should be greater than zero after reset")
        XCTAssertGreaterThan(screenSize.height,
                             0,
                             "Height should be greater than zero after reset")
    }
    
    // MARK: - Cleanup
    
    override func tearDown() {
        super.tearDown()
        // Always reset the screen size provider after each test to avoid side effects
        DispatchQueue.main.async {
            DMNativeDeviceParameters.resetScreenSizeProvider()
        }
    }
}
