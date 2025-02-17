//
//  DMErrorViewSettingsTests.swift
//  DMErrorHandling
//
//  Created by Nikolay Dementiev on 17.02.2025.
//

import XCTest
@testable import DMErrorHandling
import SwiftUI

final class DMErrorViewSettingsTests: XCTestCase {
    
    // MARK: ActionButtonSettings Tests
    
    func testActionButtonSettingsDefaultInitialization() {
        let buttonSettings = ActionButtonSettings(text: "Close")
        
        XCTAssertEqual(buttonSettings.text,
                       "Close",
                       "Default text should be 'Close'")
        XCTAssertEqual(buttonSettings.backgroundColor,
                       Color.white,
                       "Default background color should be white")
        XCTAssertEqual(buttonSettings.cornerRadius,
                       8,
                       "Default corner radius should be 8")
    }
    
    func testActionButtonSettingsCustomInitialization() {
        let customBackgroundColor = Color.red
        let customCornerRadius: CGFloat = 12
        
        let buttonSettings = ActionButtonSettings(
            text: "Retry",
            backgroundColor: customBackgroundColor,
            cornerRadius: customCornerRadius
        )
        
        XCTAssertEqual(buttonSettings.text,
                       "Retry",
                       "Text should match the custom value")
        XCTAssertEqual(buttonSettings.backgroundColor,
                       customBackgroundColor,
                       "Background color should match the custom value")
        XCTAssertEqual(buttonSettings.cornerRadius,
                       customCornerRadius,
                       "Corner radius should match the custom value")
    }
    
    // MARK: ErrorTextSettings Tests
    
    func testErrorTextSettingsDefaultInitialization() {
        let textSettings = ErrorTextSettings()
        
        XCTAssertEqual(textSettings.foregroundColor,
                       Color.white,
                       "Default foreground color should be white")
        XCTAssertEqual(textSettings.multilineTextAlignment,
                       TextAlignment.center,
                       "Default alignment should be center")
        XCTAssertEqual(textSettings.padding.top,
                       0,
                       "Default top padding should be 0")
        XCTAssertEqual(textSettings.padding.leading,
                       10,
                       "Default leading padding should be 10")
        XCTAssertEqual(textSettings.padding.bottom,
                       0,
                       "Default bottom padding should be 0")
        XCTAssertEqual(textSettings.padding.trailing,
                       10,
                       "Default trailing padding should be 10")
    }
    
    func testErrorTextSettingsCustomInitialization() {
        let customForegroundColor = Color.blue
        let customAlignment = TextAlignment.leading
        let customPadding = EdgeInsets(top: 5,
                                       leading: 15,
                                       bottom: 5,
                                       trailing: 15)
        
        let textSettings = ErrorTextSettings(
            foregroundColor: customForegroundColor,
            multilineTextAlignment: customAlignment,
            padding: customPadding
        )
        
        XCTAssertEqual(textSettings.foregroundColor,
                       customForegroundColor,
                       "Foreground color should match the custom value")
        XCTAssertEqual(textSettings.multilineTextAlignment,
                       customAlignment,
                       "Alignment should match the custom value")
        XCTAssertEqual(textSettings.padding.top,
                       5,
                       "Top padding should match the custom value")
        XCTAssertEqual(textSettings.padding.leading,
                       15,
                       "Leading padding should match the custom value")
        XCTAssertEqual(textSettings.padding.bottom,
                       5,
                       "Bottom padding should match the custom value")
        XCTAssertEqual(textSettings.padding.trailing,
                       15,
                       "Trailing padding should match the custom value")
    }
    
    func testErrorTextSettingsWithNilForegroundColor() {
        let textSettings = ErrorTextSettings(foregroundColor: nil)
        
        XCTAssertNil(textSettings.foregroundColor,
                     "Foreground color should be nil when explicitly set to nil")
    }
    
    // MARK: ErrorImageSettings Tests
    
    func testErrorImageSettingsDefaultInitialization() {
        let imageSettings = ErrorImageSettings(
            image: Image(systemName: "exclamationmark.triangle")
        )
        
        XCTAssertEqual(imageSettings.image,
                       Image(systemName: "exclamationmark.triangle"),
                       "Default image should be 'exclamationmark.triangle'")
        XCTAssertEqual(imageSettings.foregroundColor,
                       Color.red,
                       "Default foreground color should be red")
        XCTAssertEqual(imageSettings.frameSize.width,
                       50,
                       "Default width should be 50")
        XCTAssertEqual(imageSettings.frameSize.height,
                       50,
                       "Default height should be 50")
    }
    
    func testErrorImageSettingsCustomInitialization() {
        let customImage = Image(systemName: "xmark.circle")
        let customForegroundColor = Color.green
        let customFrameSize = CustomSizeView(width: 100,
                                             height: 100)
        
        let imageSettings = ErrorImageSettings(
            image: customImage,
            foregroundColor: customForegroundColor,
            frameSize: customFrameSize
        )
        
        XCTAssertEqual(imageSettings.image,
                       customImage,
                       "Image should match the custom value")
        XCTAssertEqual(imageSettings.foregroundColor,
                       customForegroundColor,
                       "Foreground color should match the custom value")
        XCTAssertEqual(imageSettings.frameSize.width,
                       100,
                       "Width should match the custom value")
        XCTAssertEqual(imageSettings.frameSize.height,
                       100,
                       "Height should match the custom value")
    }
    
    func testErrorImageSettingsWithNilForegroundColor() {
        let imageSettings = ErrorImageSettings(
            image: Image(systemName: "exclamationmark.triangle"),
            foregroundColor: nil
        )
        
        XCTAssertNil(imageSettings.foregroundColor,
                     "Foreground color should be nil when explicitly set to nil")
    }
    
    // MARK: DMErrorDefaultViewSettings Tests
    
    func testDMErrorDefaultViewSettingsDefaultInitialization() {
        let settings = DMErrorDefaultViewSettings()
        
        XCTAssertEqual(settings.errorText,
                       "An error has occured!",
                       "Default error text should be 'An error has occured!'")
        XCTAssertEqual(settings.actionButtonCloseSettings.text,
                       "Close",
                       "Default close button text should be 'Close'")
        XCTAssertEqual(settings.actionButtonRetrySettings.text,
                       "Retry",
                       "Default retry button text should be 'Retry'")
        XCTAssertEqual(settings.errorTextSettings.foregroundColor,
                       Color.white,
                       "Default error text foreground color should be white")
        XCTAssertEqual(settings.errorImageSettings.image,
                       Image(systemName: "exclamationmark.triangle"),
                       "Default image should be 'exclamationmark.triangle'")
    }
    
    func testDMErrorDefaultViewSettingsCustomInitialization() {
        let customErrorText = "Custom error message"
        let customCloseButtonSettings = ActionButtonSettings(
            text: "Dismiss",
            backgroundColor: Color.blue,
            cornerRadius: 10
        )
        let customRetryButtonSettings = ActionButtonSettings(
            text: "Try Again",
            backgroundColor: Color.green,
            cornerRadius: 12
        )
        let customErrorTextSettings = ErrorTextSettings(
            foregroundColor: Color.red,
            multilineTextAlignment: TextAlignment.trailing,
            padding: EdgeInsets(top: 10,
                                leading: 20,
                                bottom: 10,
                                trailing: 20)
        )
        let customErrorImageSettings = ErrorImageSettings(
            image: Image(systemName: "xmark.circle"),
            foregroundColor: Color.yellow,
            frameSize: CustomSizeView(width: 80,
                                      height: 80)
        )
        
        let settings = DMErrorDefaultViewSettings(
            errorText: customErrorText,
            actionButtonCloseSettings: customCloseButtonSettings,
            actionButtonRetrySettings: customRetryButtonSettings,
            errorTextSettings: customErrorTextSettings,
            errorImageSettings: customErrorImageSettings
        )
        
        XCTAssertEqual(settings.errorText,
                       customErrorText,
                       "Error text should match the custom value")
        XCTAssertEqual(settings.actionButtonCloseSettings.text,
                       "Dismiss",
                       "Close button text should match the custom value")
        XCTAssertEqual(settings.actionButtonRetrySettings.text,
                       "Try Again",
                       "Retry button text should match the custom value")
        XCTAssertEqual(settings.errorTextSettings.foregroundColor,
                       Color.red,
                       "Error text foreground color should match the custom value")
        XCTAssertEqual(settings.errorImageSettings.image,
                       Image(systemName: "xmark.circle"),
                       "Image should match the custom value")
    }
}
