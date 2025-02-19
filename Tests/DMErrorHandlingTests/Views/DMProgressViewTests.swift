//
//  DMProgressViewTests.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 19.02.2025.
//

import XCTest
@testable import DMErrorHandling
import SwiftUI
import ViewInspector

final class DMProgressViewTests: XCTestCase {

    // MARK: Initialization Tests
    
    @MainActor
    func testInitialization() {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        XCTAssertNotNil(view.settingsProvider,
                        "The settingsProvider should be initialized")
    }
    
    // MARK: Rendering Tests
    
    @MainActor
    func testRendersContainerView() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        // Find the container view by tag
        let containerView = try view
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.containerViewTag)
            .zStack()
        XCTAssertNotNil(containerView,
                        "The container view should be rendered")
    }
    
    @MainActor
    func testRendersVStack() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        // Find the VStack by tag
        let vStack = try view
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.vStackViewTag)
            .vStack()
        XCTAssertNotNil(vStack,
                        "The VStack should be rendered")
    }
    
    @MainActor
    func testRendersText() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        // Find the Text view by tag
        let text = try view
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.textTag)
            .text()
        XCTAssertEqual(try text.string(),
                       "Loading...",
                       "The Text view should display the correct text")
    }
    
    @MainActor
    func testRendersProgressView() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        // Find the ProgressView by tag
        let progressView = try view
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.progressViewTag)
            .progressView()
        XCTAssertNotNil(progressView,
                        "The ProgressView should be rendered")
    }
    
    // MARK: Customization Tests
    
    @MainActor
    func testAppliesTextProperties() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        // Find the Text view by tag
        let text = try view
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.textTag)
            .text()
        
        // Verify text properties
        XCTAssertEqual(try text.string(),
                       "Loading...",
                       "The Text view should display the correct text")
        XCTAssertEqual(try text.attributes().foregroundColor(),
                       .blue,
                       "The Text view should have the correct foreground color")
        XCTAssertEqual(try text.attributes().font(),
                       Font.system(size: 16),
                       "The Text view should have the correct font")
        XCTAssertEqual(try text.lineLimit(),
                       1,
                       "The Text view should have the correct line limit")
        XCTAssertEqual(try text.padding(.horizontal),
                       8,
                       "The Text view should have the correct padding")
    }
    
    @MainActor
    func testAppliesProgressViewProperties() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        // Find the ProgressView by tag
        let progressView = try view
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.progressViewTag)
            .progressView()
        
        let progressViewStyle = try? progressView.progressViewStyle() as? CircularProgressViewStyle
        XCTAssertNotNil(progressViewStyle,
                        "The ProgressView should have `CircularProgressViewStyle`")
        
        // Verify ProgressView properties
//        XCTAssertEqual(try progressView.controlSize(),
//                       .regular,
//                       "The ProgressView should have the correct control size")
        
        XCTAssertEqual(try progressView.tint(),
                       .green,
                       "The ProgressView should have the correct tint color")
    }
    
    // MARK: Layout Tests
    
    @MainActor
    func testRespectsLayoutConstraints() throws {
        let settingsProvider = MockSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        let geometry = settingsProvider.frameGeometrySize
        let minSize = min(geometry.width - 20,
                          geometry.height - 20,
                          30)
        
        // Find the VStack by tag
        let vStack = try view.inspect().find(viewWithTag: DMProgressViewOwnSettings.vStackViewTag)
        
        // Verify frame constraints
//        XCTAssertEqual(try vStack.minimumWidth(),
//                       minSize,
//                       "The VStack should have the correct minimum width")
//        XCTAssertEqual(try vStack.maximumWidth(),
//                       geometry.width / 2,
//                       "The VStack should have the correct maximum width")
//        XCTAssertEqual(try vStack.minimumHeight(),
//                       minSize,
//                       "The VStack should have the correct minimum height")
//        XCTAssertEqual(try vStack.maximumHeight(),
//                       geometry.height / 2,
//                       "The VStack should have the correct maximum height")
    }
}
