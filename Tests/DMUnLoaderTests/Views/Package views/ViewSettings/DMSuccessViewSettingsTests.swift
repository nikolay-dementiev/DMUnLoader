//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI

final class DMSuccessViewSettingsTests: XCTestCase {
    
    // MARK: - SuccessImageProperties Tests
    
    func testSuccessImagePropertiesDefaultInitialization() {
        let imageProperties = SuccessImageProperties()
        
        XCTAssertEqual(
            imageProperties.image,
            Image(systemName: "checkmark.circle.fill"),
            "Default image should be 'checkmark.circle.fill'"
        )
        XCTAssertEqual(
            imageProperties.frame.width,
            50,
            "Default width should be 50"
        )
        XCTAssertEqual(
            imageProperties.frame.height,
            50,
            "Default height should be 50"
        )
        XCTAssertEqual(
            imageProperties.foregroundColor,
            Color.green,
            "Default foreground color should be green"
        )
    }
    
    func testSuccessImagePropertiesCustomInitialization() {
        let customImage = Image(systemName: "star.fill")
        let customFrame = CustomSizeView(
            width: 100,
            height: 100
        )
        let customForegroundColor = Color.red
        
        let imageProperties = SuccessImageProperties(
            image: customImage,
            frame: customFrame,
            foregroundColor: customForegroundColor
        )
        
        XCTAssertEqual(
            imageProperties.image,
            customImage,
            "Image should match the custom value"
        )
        XCTAssertEqual(
            imageProperties.frame.width,
            100,
            "Width should match the custom value"
        )
        XCTAssertEqual(
            imageProperties.frame.height,
            100,
            "Height should match the custom value"
        )
        XCTAssertEqual(
            imageProperties.foregroundColor,
            customForegroundColor,
            "Foreground color should match the custom value"
        )
    }
    
    func testSuccessImagePropertiesWithNilForegroundColor() {
        let imageProperties = SuccessImageProperties(
            foregroundColor: nil
        )
        
        XCTAssertNil(
            imageProperties.foregroundColor,
            "Foreground color should be nil when explicitly set to nil"
        )
    }
    
    // MARK: - SuccessTextProperties Tests
    
    func testSuccessTextPropertiesDefaultInitialization() {
        let textProperties = SuccessTextProperties()
        
        XCTAssertEqual(
            textProperties.text,
            "Success!",
            "Default text should be 'Success!'"
        )
        XCTAssertEqual(
            textProperties.foregroundColor,
            Color.white,
            "Default foreground color should be white"
        )
    }
    
    func testSuccessTextPropertiesCustomInitialization() {
        let customText = "Custom Success!"
        let customForegroundColor = Color.blue
        
        let textProperties = SuccessTextProperties(
            text: customText,
            foregroundColor: customForegroundColor
        )
        
        XCTAssertEqual(
            textProperties.text,
            customText,
            "Text should match the custom value"
        )
        XCTAssertEqual(
            textProperties.foregroundColor,
            customForegroundColor,
            "Foreground color should match the custom value"
        )
    }
    
    func testSuccessTextPropertiesWithNilValues() {
        let textProperties = SuccessTextProperties(
            text: nil,
            foregroundColor: nil
        )
        
        XCTAssertNil(
            textProperties.text,
            "Text should be nil when explicitly set to nil"
        )
        XCTAssertNil(
            textProperties.foregroundColor,
            "Foreground color should be nil when explicitly set to nil"
        )
    }
    
    // MARK: - DMSuccessDefaultViewSettings Tests
    
    func testDMSuccessDefaultViewSettingsDefaultInitialization() {
        let settings = DMSuccessDefaultViewSettings()
        
        XCTAssertEqual(
            settings.successImageProperties.image,
            Image(systemName: "checkmark.circle.fill"),
            "Default image should be 'checkmark.circle.fill'"
        )
        XCTAssertEqual(
            settings.successImageProperties.frame.width,
            50,
            "Default width should be 50"
        )
        XCTAssertEqual(
            settings.successImageProperties.frame.height,
            50,
            "Default height should be 50"
        )
        XCTAssertEqual(
            settings.successImageProperties.foregroundColor,
            Color.green,
            "Default foreground color should be green"
        )
        
        XCTAssertEqual(
            settings.successTextProperties.text,
            "Success!",
            "Default text should be 'Success!'"
        )
        XCTAssertEqual(
            settings.successTextProperties.foregroundColor,
            Color.white,
            "Default foreground color should be white"
        )
    }
    
    func testDMSuccessDefaultViewSettingsCustomInitialization() {
        let customImageProperties = SuccessImageProperties(
            image: Image(systemName: "star.fill"),
            frame: CustomSizeView(
                width: 100,
                height: 100
            ),
            foregroundColor: Color.red
        )
        let customTextProperties = SuccessTextProperties(
            text: "Custom Success!",
            foregroundColor: Color.blue
        )
        
        let settings = DMSuccessDefaultViewSettings(
            successImageProperties: customImageProperties,
            successTextProperties: customTextProperties
        )
        
        XCTAssertEqual(
            settings.successImageProperties.image,
            Image(systemName: "star.fill"),
            "Image should match the custom value"
        )
        XCTAssertEqual(
            settings.successImageProperties.frame.width,
            100,
            "Width should match the custom value"
        )
        XCTAssertEqual(
            settings.successImageProperties.frame.height,
            100,
            "Height should match the custom value"
        )
        XCTAssertEqual(
            settings.successImageProperties.foregroundColor,
            Color.red,
            "Foreground color should match the custom value"
        )
        
        XCTAssertEqual(
            settings.successTextProperties.text,
            "Custom Success!",
            "Text should match the custom value"
        )
        XCTAssertEqual(
            settings.successTextProperties.foregroundColor,
            Color.blue,
            "Foreground color should match the custom value"
        )
    }
}
