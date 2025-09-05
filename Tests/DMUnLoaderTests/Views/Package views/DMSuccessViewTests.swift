//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI
import ViewInspector

final class DMSuccessViewTests: XCTestCase {
    
    // MARK: Initialization Tests
    
    @MainActor
    func testInitialization() {
        let settingsProvider = MockDMSuccessViewSettings()
        let successObject = MockDMLoadableTypeSuccess()
        let view = DMSuccessView(settings: settingsProvider,
                                 assosiatedObject: successObject)
        
        XCTAssertNotNil(view.settingsProvider,
                        "The settingsProvider should be initialized")
        XCTAssertNotNil(view.assosiatedObject,
                        "The associated object should be initialized")
    }
    
    // MARK: Rendering Tests
    
    @MainActor
    func testRendersContainerView() throws {
        let settingsProvider = MockDMSuccessViewSettings()
        let successObject = MockDMLoadableTypeSuccess()
        let view = DMSuccessView(settings: settingsProvider,
                                 assosiatedObject: successObject)
        
        let containerView = try? view
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.containerViewTag)
            .vStack()
        
        XCTAssertNotNil(containerView,
                        "The container view should be rendered")
    }
    
    @MainActor
    func testRendersImageView() throws {
        let settingsProvider = MockDMSuccessViewSettings()
        let successObject = MockDMLoadableTypeSuccess()
        let view = DMSuccessView(settings: settingsProvider,
                                 assosiatedObject: successObject)
        
        let imageView = try? view
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.imageTag)
            .image()
        XCTAssertNotNil(imageView,
                        "The ImageView should be rendered")
        
        let fixedImageFrame = try? imageView?.fixedFrame()
        let successImageProperties = settingsProvider.successImageProperties
        
        XCTAssertEqual(fixedImageFrame?.width,
                       successImageProperties.frame.width,
                       "The ImageView frame should have the correct frame width")
        XCTAssertEqual(fixedImageFrame?.height,
                       successImageProperties.frame.height,
                       "The ImageView height should have the correct frame height")
        XCTAssertEqual(fixedImageFrame?.alignment,
                       successImageProperties.frame.alignment,
                       "The ImageView frame should have the correct frame alignment")
        
        XCTAssertEqual(try? imageView?.foregroundColor(),
                       successImageProperties.foregroundColor,
                       "The ImageView should have the correct foreground color")
    }
    
    @MainActor
    func testRendersTextFromAssociatedObject() throws {
        let settingsProvider = MockDMSuccessViewSettings()
        let successObject = MockDMLoadableTypeSuccess(description: "Custom Success Message")
        let view = DMSuccessView(settings: settingsProvider,
                                 assosiatedObject: successObject)
        
        let textView = try? view
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.textTag)
            .text()
        XCTAssertNotNil(textView,
                        "The Text view should be rendered")
        
        XCTAssertEqual(try? textView?.string(),
                       successObject.description,
                       "The Text view should display the custom success message from the associated object")
        XCTAssertEqual(try? textView?.attributes().foregroundColor(),
                       settingsProvider.successTextProperties.foregroundColor,
                       "The Text view should have the correct foreground color")
    }
    
    @MainActor
    func testRendersTextFromSettingsProvider() throws {
        let settingsProvider = MockDMSuccessViewSettings()
        let successObject: MockDMLoadableTypeSuccess? = nil
        let view = DMSuccessView(settings: settingsProvider,
                                 assosiatedObject: successObject)
        
        let textView = try view
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.textTag)
            .text()
        XCTAssertNotNil(textView,
                        "The Text view should be rendered")
        
        XCTAssertEqual(try? textView.string(),
                       settingsProvider.successTextProperties.text,
                       "The Text view should display the default success text from the settings provider")
        XCTAssertEqual(try? textView.attributes().foregroundColor(),
                       settingsProvider.successTextProperties.foregroundColor,
                       "The Text view should have the correct foreground color")
    }
}
