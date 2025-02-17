//
//  DMLoadingViewSettingsTests.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 17.02.2025.
//

import XCTest
@testable import DMErrorHandling
import SwiftUI

final class DMLoadingViewSettingsTests: XCTestCase {
    
    // MARK: LoadingTextProperties Tests
    
    func testLoadingTextPropertiesDefaultInitialization() {
        let textProperties = LoadingTextProperties()
        
        XCTAssertEqual(textProperties.text,
                       "Loading...",
                       "Default text should be 'Loading...'")
        XCTAssertEqual(textProperties.alignment,
                       TextAlignment.center,
                       "Default alignment should be center")
        XCTAssertEqual(textProperties.foregroundColor,
                       Color.white,
                       "Default foreground color should be white")
        XCTAssertEqual(textProperties.font,
                       Font.body,
                       "Default font should be body")
        XCTAssertEqual(textProperties.lineLimit,
                       3,
                       "Default line limit should be 3")
        XCTAssertEqual(textProperties.linePadding.top,
                       0,
                       "Default top padding should be 0")
        XCTAssertEqual(textProperties.linePadding.leading,
                       10,
                       "Default leading padding should be 10")
        XCTAssertEqual(textProperties.linePadding.bottom,
                       0,
                       "Default bottom padding should be 0")
        XCTAssertEqual(textProperties.linePadding.trailing,
                       10,
                       "Default trailing padding should be 10")
    }
    
    func testLoadingTextPropertiesCustomInitialization() {
        let customText = "Please wait..."
        let customAlignment = TextAlignment.leading
        let customForegroundColor = Color.red
        let customFont = Font.largeTitle
        let customLineLimit: Int? = nil
        let customLinePadding = EdgeInsets(top: 5,
                                           leading: 15,
                                           bottom: 5,
                                           trailing: 15)
        
        let textProperties = LoadingTextProperties(
            text: customText,
            alignment: customAlignment,
            foregroundColor: customForegroundColor,
            font: customFont,
            lineLimit: customLineLimit,
            linePadding: customLinePadding
        )
        
        XCTAssertEqual(textProperties.text,
                       customText,
                       "Text should match the custom value")
        XCTAssertEqual(textProperties.alignment,
                       customAlignment,
                       "Alignment should match the custom value")
        XCTAssertEqual(textProperties.foregroundColor,
                       customForegroundColor,
                       "Foreground color should match the custom value")
        XCTAssertEqual(textProperties.font,
                       customFont,
                       "Font should match the custom value")
        XCTAssertNil(textProperties.lineLimit,
                     "Line limit should be nil when explicitly set to nil")
        XCTAssertEqual(textProperties.linePadding.top,
                       5,
                       "Top padding should match the custom value")
        XCTAssertEqual(textProperties.linePadding.leading,
                       15,
                       "Leading padding should match the custom value")
        XCTAssertEqual(textProperties.linePadding.bottom,
                       5,
                       "Bottom padding should match the custom value")
        XCTAssertEqual(textProperties.linePadding.trailing,
                       15,
                       "Trailing padding should match the custom value")
    }
    
    // MARK: ProgressIndicatorProperties Tests
    
    func testProgressIndicatorPropertiesDefaultInitialization() {
        let indicatorProperties = ProgressIndicatorProperties()
        
        XCTAssertEqual(indicatorProperties.size,
                       ControlSize.large,
                       "Default size should be large")
        XCTAssertEqual(indicatorProperties.tintColor,
                       Color.white,
                       "Default tint color should be white")
    }
    
    func testProgressIndicatorPropertiesCustomInitialization() {
        let customSize = ControlSize.small
        let customTintColor = Color.blue
        
        let indicatorProperties = ProgressIndicatorProperties(
            size: customSize,
            tintColor: customTintColor
        )
        
        XCTAssertEqual(indicatorProperties.size,
                       customSize,
                       "Size should match the custom value")
        XCTAssertEqual(indicatorProperties.tintColor,
                       customTintColor,
                       "Tint color should match the custom value")
    }
    
    func testProgressIndicatorPropertiesWithNilTintColor() {
        let indicatorProperties = ProgressIndicatorProperties(tintColor: nil)
        
        XCTAssertNil(indicatorProperties.tintColor,
                     "Tint color should be nil when explicitly set to nil")
    }
    
    // MARK: DMLoadingDefaultViewSettings Tests
    
    func testDMLoadingDefaultViewSettingsDefaultInitialization() {
        let settings = DMLoadingDefaultViewSettings()
        
        XCTAssertEqual(settings.loadingTextProperties.text,
                       "Loading...",
                       "Default text should be 'Loading...'")
        XCTAssertEqual(settings.progressIndicatorProperties.size,
                       ControlSize.large,
                       "Default progress indicator size should be large")
        XCTAssertEqual(settings.progressIndicatorProperties.tintColor,
                       Color.white,
                       "Default progress indicator tint color should be white")
        XCTAssertEqual(settings.loadingContainerForegroundColor,
                       Color.primary,
                       "Default container foreground color should be primary")
        XCTAssertEqual(settings.frameGeometrySize.width,
                       300,
                       "Default width should be 300")
        XCTAssertEqual(settings.frameGeometrySize.height,
                       300,
                       "Default height should be 300")
    }
    
    func testDMLoadingDefaultViewSettingsCustomInitialization() {
        let customTextProperties = LoadingTextProperties(
            text: "Please wait...",
            alignment: .leading,
            foregroundColor: Color.red,
            font: Font.largeTitle,
            lineLimit: nil,
            linePadding: EdgeInsets(top: 5,
                                    leading: 15,
                                    bottom: 5,
                                    trailing: 15)
        )
        let customIndicatorProperties = ProgressIndicatorProperties(
            size: .small,
            tintColor: Color.blue
        )
        let customContainerForegroundColor = Color.green
        let customFrameGeometrySize = CGSize(width: 400,
                                             height: 400)
        
        let settings = DMLoadingDefaultViewSettings(
            loadingTextProperties: customTextProperties,
            progressIndicatorProperties: customIndicatorProperties,
            loadingContainerForegroundColor: customContainerForegroundColor,
            frameGeometrySize: customFrameGeometrySize
        )
        
        XCTAssertEqual(settings.loadingTextProperties.text,
                       "Please wait...",
                       "Text should match the custom value")
        XCTAssertEqual(settings.progressIndicatorProperties.size,
                       .small,
                       "Progress indicator size should match the custom value")
        XCTAssertEqual(settings.progressIndicatorProperties.tintColor,
                       Color.blue,
                       "Progress indicator tint color should match the custom value")
        XCTAssertEqual(settings.loadingContainerForegroundColor,
                       Color.green,
                       "Container foreground color should match the custom value")
        XCTAssertEqual(settings.frameGeometrySize.width,
                       400,
                       "Width should match the custom value")
        XCTAssertEqual(settings.frameGeometrySize.height,
                       400,
                       "Height should match the custom value")
    }
}
