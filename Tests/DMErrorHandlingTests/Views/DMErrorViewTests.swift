////
////  DMErrorHandling
////
////  Created by Mykola Dementiev
////
//
//
//import XCTest
//@testable import DMErrorHandling
//import SwiftUI
//import ViewInspector
//
//final class DMErrorViewTests: XCTestCase {
//    
//    // MARK: Mock Dependencies
//    
//    
//    
//    // MARK: Initialization Tests
//    
//    func testInitialization() {
//        let settingsProvider = MockErrorViewSettingsProvider()
//        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
//        let onClose = { }
//        let onRetry = { }
//        
//        let view = DMErrorView(settings: settingsProvider,
//                               error: error,
//                               onRetry: onRetry,
//                               onClose: onClose)
//        
//        XCTAssertNotNil(view.settingsProvider, "The settingsProvider should be initialized")
//        XCTAssertNotNil(view.error, "The error should be initialized")
//        XCTAssertNotNil(view.onClose, "The onClose action should be initialized")
//    }
//    
//    // MARK: Rendering Tests
//    
//    func testRendersContainerVStack() throws {
//        let settingsProvider = MockErrorViewSettingsProvider()
//        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
//        let onClose = { }
//        let view = DMErrorView(settings: settingsProvider,
//                               error: error,
//                               onClose: onClose)
//        
//        // Find the container VStack by tag
//        let containerVStack = try view.inspect().find(viewWithTag: DMErrorViewOwnSettings.containerVStackViewTag)
//        XCTAssertNotNil(containerVStack, "The container VStack should be rendered")
//    }
//    
//    func testRendersImageView() throws {
//        let settingsProvider = MockErrorViewSettingsProvider()
//        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
//        let onClose = { }
//        let view = DMErrorView(settings: settingsProvider,
//                               error: error,
//                               onClose: onClose)
//        
//        // Find the ImageView by tag
//        let imageView = try view.inspect().find(viewWithTag: DMErrorViewOwnSettings.imageViewTag).image()
//        XCTAssertNotNil(imageView, "The ImageView should be rendered")
//        XCTAssertEqual(try imageView.frame(), CGRect(x: 0, y: 0, width: 50, height: 50), "The ImageView should have the correct frame size")
//        XCTAssertEqual(try imageView.foregroundColor(), .red, "The ImageView should have the correct foreground color")
//    }
//    
//    func testRendersErrorTextFromProvider() throws {
//        let settingsProvider = MockErrorViewSettingsProvider()
//        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
//        let onClose = { }
//        let view = DMErrorView(settings: settingsProvider,
//                               error: error,
//                               onClose: onClose)
//        
//        // Find the ErrorText from provider by tag
//        let errorText = try view.inspect().find(viewWithTag: DMErrorViewOwnSettings.errorTextFormProviderContainerViewTag).text()
//        XCTAssertEqual(try errorText.string(), "An error occurred", "The ErrorText should display the correct text from the provider")
//        XCTAssertEqual(try errorText.foregroundColor(), .black, "The ErrorText should have the correct foreground color")
//    }
//    
//    func testRendersErrorTextFromException() throws {
//        let settingsProvider = MockErrorViewSettingsProvider()
//        let error = NSError(domain: "TestError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
//        let onClose = { }
//        let view = DMErrorView(settings: settingsProvider,
//                               error: error,
//                               onClose: onClose)
//        
//        // Find the ErrorText from exception by tag
//        let errorText = try view.inspect().find(viewWithTag: DMErrorViewOwnSettings.errorTextFormExeptionContainerViewTag).text()
//        XCTAssertEqual(try errorText.string(), "Something went wrong", "The ErrorText should display the correct localized description")
//    }
//    
//    func testRendersActionButtonClose() throws {
//        let settingsProvider = MockErrorViewSettingsProvider()
//        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
//        let onClose = { }
//        let view = DMErrorView(settings: settingsProvider,
//                               error: error,
//                               onClose: onClose)
//        
//        // Find the Close Button by tag
//        let closeButton = try view.inspect().find(viewWithTag: DMErrorViewOwnSettings.actionButtonCloseViewTag).button()
//        XCTAssertEqual(try closeButton.labelView().string(), "Close", "The Close Button should display the correct label")
//        XCTAssertEqual(try closeButton.background(Color.self), .blue, "The Close Button should have the correct background color")
//    }
//    
//    func testRendersActionButtonRetry() throws {
//        let settingsProvider = MockErrorViewSettingsProvider()
//        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
//        let onClose = { }
//        let onRetry = { }
//        let view = DMErrorView(settings: settingsProvider,
//                               error: error,
//                               onRetry: onRetry,
//                               onClose: onClose)
//        
//        // Find the Retry Button by tag
//        let retryButton = try view.inspect().find(viewWithTag: DMErrorViewOwnSettings.actionButtonRetryViewTag).button()
//        XCTAssertEqual(try retryButton.labelView().string(), "Retry", "The Retry Button should display the correct label")
//        XCTAssertEqual(try retryButton.background(Color.self), .green, "The Retry Button should have the correct background color")
//    }
//    
//    func testRendersButtonContainersHStack() throws {
//        let settingsProvider = MockErrorViewSettingsProvider()
//        let error = NSError(domain: "TestError", code: 1, userInfo: nil)
//        let onClose = { }
//        let view = DMErrorView(settings: settingsProvider,
//                               error: error,
//                               onClose: onClose)
//        
//        // Find the HStack containing buttons by tag
//        let hStack = try view.inspect().find(viewWithTag: DMErrorViewOwnSettings.buttonContainersHStackViewTag)
//        XCTAssertNotNil(hStack, "The HStack containing buttons should be rendered")
//    }
//}
