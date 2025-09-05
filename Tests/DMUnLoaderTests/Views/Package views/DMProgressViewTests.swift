//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI
import ViewInspector

final class DMProgressViewTests: XCTestCase {

    // MARK: Initialization Tests
    
    @MainActor
    func testInitialization() {
        let settingsProvider = MockLoadingViewSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        XCTAssertNotNil(view.settingsProvider,
                        "The settingsProvider should be initialized")
    }
    
    // MARK: Rendering Tests
    
    @MainActor
    func testRendersContainerView() throws {
        let settingsProvider = MockLoadingViewSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        let containerView = try view
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.containerViewTag)
            .zStack()
        XCTAssertNotNil(containerView,
                        "The container view should be rendered")
    }
    
    @MainActor
    func testRendersVStack() throws {
        let settingsProvider = MockLoadingViewSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        let vStack = try view
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.vStackViewTag)
            .vStack()
        XCTAssertNotNil(vStack,
                        "The VStack should be rendered")
    }
    
    @MainActor
    func testRendersText() throws {
        let settingsProvider = MockLoadingViewSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
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
        let settingsProvider = MockLoadingViewSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
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
        let settingsProvider = MockLoadingViewSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        let text = try view
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.textTag)
            .text()
        
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
        let settingsProvider = MockLoadingViewSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        let progressView = try view
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.progressViewTag)
            .progressView()
        
        let progressViewStyle = try? progressView.progressViewStyle() as? CircularProgressViewStyle
        XCTAssertNotNil(progressViewStyle,
                        "The ProgressView should be `CircularProgressViewStyle` type")
        
        let progressViewLayoutPriority = try? progressView.layoutPriority()
        XCTAssertEqual(progressViewLayoutPriority,
                       1,
                       "The ProgressView should have layout priority equal `1`")
        XCTAssertEqual(try progressView.tint(),
                       .green,
                       "The ProgressView should have the correct tint color")
        /* Not implemented in ViewInspector for iOS
        XCTAssertEqual(try progressView.controlSize(),
                       .regular,
                       "The ProgressView should have the correct control size")
        */
    }
    
    // MARK: Layout Tests
    
    @MainActor
    func testRespectsLayoutConstraints() throws {
        let settingsProvider = MockLoadingViewSettingsProvider()
        let view = DMProgressView(settings: settingsProvider)
        
        let geometry = settingsProvider.frameGeometrySize
        let minSize = min(geometry.width - 20,
                          geometry.height - 20,
                          30)
        
        let vStack = try view
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.vStackViewTag)
            .vStack()
        
        let flexFrame = try? vStack.flexFrame()
        
        XCTAssertEqual(flexFrame?.minWidth,
                       minSize,
                       "The VStack should have the correct minimum width")
        XCTAssertEqual(flexFrame?.maxWidth,
                       geometry.width / 2,
                       "The VStack should have the correct maximum width")
        XCTAssertEqual(flexFrame?.minHeight,
                       minSize,
                       "The VStack should have the correct minimum height")
        XCTAssertEqual(flexFrame?.maxHeight,
                       geometry.height / 2,
                       "The VStack should have the correct maximum height")
        
        XCTAssertEqual(try? vStack.foregroundColor(),
                       settingsProvider.loadingContainerForegroundColor,
                       "The foreground color of the VStack should match the loading container foreground color")
    }
}
