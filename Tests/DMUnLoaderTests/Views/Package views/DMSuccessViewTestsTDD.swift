//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI
import ViewInspector

private struct DMSuccessViewTDD: View {
    let settingsProvider: DMSuccessViewSettings
    
    init(settings settingsProvider: DMSuccessViewSettings) {
        self.settingsProvider = settingsProvider
    }
    
    var body: some View {
        let successImageProperties = settingsProvider.successImageProperties
        
        VStack {
            successImageProperties.image
//                .resizable()
                .frame(width: successImageProperties.frame.width,
                       height: successImageProperties.frame.height,
                       alignment: successImageProperties.frame.alignment)
                .foregroundColor(successImageProperties.foregroundColor)
                .tag(DMSuccessViewOwnSettings.imageTag)
            
            let successTextProperties = settingsProvider.successTextProperties
            if let successText = successTextProperties.text {
                Text(successText)
                    .foregroundColor(successTextProperties.foregroundColor)
                    .tag(DMSuccessViewOwnSettings.textTag)
            }
        }
        .tag(DMSuccessViewOwnSettings.containerViewTag)
    }
}

@MainActor
final class DMSuccessViewTestsTDD: XCTestCase {

    // MARK: Scenario 1: Verify Default Initialization
    
    func testDefaultInitialization() {
        let settings = DMSuccessDefaultViewSettings()
        let sut = makeSUT(settings: settings)
        
        XCTAssertNotNil(sut.settingsProvider,
                        "The settingsProvider should be initialized")
    }
    
    func testImageRenderedCorrectlyDuringDefaultInitialization() throws {
        let settings = DMSuccessDefaultViewSettings()
        let sut = makeSUT(settings: settings)
        
        let image = try sut
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.imageTag)
            .image()

        try sutImageNameConfirmToExpectedImage(
            sutImage: image,
            expectedImage: settings.successImageProperties.image,
            expectedImageName: "checkmark.circle.fill"
        )
    }
    
    func testTextRenderedCorrectlyDuringDefaultInitialization() throws {
        let settings = DMSuccessDefaultViewSettings()
        let sut = makeSUT(settings: settings)
        
        let text = try sut
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.textTag)
            .text()
        
        XCTAssertNotNil(text,
                        "The TextView should be rendered")

        let textFormSUT = try? text.string()
        XCTAssertEqual(textFormSUT,
                       settings.successTextProperties.text,
                       "The default success text should match the settings")
        XCTAssertEqual(textFormSUT,
                       "Success!",
                       "The default success text should match the settings")
    }
    
    // MARK: Scenario 2: Verify Success Image Behavior
    
    func testCustomSuccessImageRendering() throws {
        let settings = DMSuccessDefaultViewSettings(
            successImageProperties: .init(
                image: Image(systemName: "star.fill"),
                frame: CustomViewSize(width: 60, height: 60),
                foregroundColor: .yellow
            )
        )
        let sut = makeSUT(settings: settings)
        
        let image = try sut
            .inspect()
            .find(viewWithTag: DMSuccessViewOwnSettings.imageTag)
            .image()
        
        try sutImageNameConfirmToExpectedImage(
            sutImage: image,
            expectedImage: settings.successImageProperties.image,
            expectedImageName: "star.fill"
        )
        
        try sutImageForegroundColorConfirmToExpectedColor(
            sutImage: image,
            expectedForegroundColorInSettings: settings.successImageProperties.foregroundColor,
            expectedForegroundColor: .yellow
        )
        
        try sutImageFrameSizeConfirmToExpectedsize(
            sutImage: image,
            expectedSizeInSettings: settings.successImageProperties.frame,
            expectedsize: CustomViewSize(width: 60, height: 60)
        )
    }
    
    private func sutImageNameConfirmToExpectedImage(
        sutImage: InspectableView<ViewType.Image>,
        expectedImage: Image,
        expectedImageName: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let imageFormSUT = try sutImage.actualImage().name()
        
        XCTAssertEqual(
            imageFormSUT,
            try expectedImage.name(),
            "The custom success image should match the settings"
        )
        XCTAssertEqual(
            imageFormSUT,
            expectedImageName,
            "The custom success image should be '\(expectedImageName)'"
        )
    }
    
    private func sutImageForegroundColorConfirmToExpectedColor(
        sutImage: InspectableView<ViewType.Image>,
        expectedForegroundColorInSettings: Color?,
        expectedForegroundColor: Color,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let imageForegroundColorFormSUT = try sutImage.foregroundColor()
        
        XCTAssertEqual(
            imageForegroundColorFormSUT,
            expectedForegroundColorInSettings,
            "Success image foreground color should match the settings"
        )
        XCTAssertEqual(
            imageForegroundColorFormSUT,
            expectedForegroundColor,
            "Success image foreground color should be \(expectedForegroundColor)"
        )
    }
    
    private func sutImageFrameSizeConfirmToExpectedsize(
        sutImage: InspectableView<ViewType.Image>,
        expectedSizeInSettings: CustomViewSize,
        expectedsize: CustomViewSize,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let fixedImageFrame = try sutImage.fixedFrame()
        
        [
            "Settings size": expectedSizeInSettings,
            "Expected size": expectedsize
        ]
            .forEach { key, value in
                XCTAssertEqual(fixedImageFrame.width,
                               value.width,
                               "The ImageView `\(key)` frame should have the correct frame width")
                XCTAssertEqual(fixedImageFrame.height,
                               value.height,
                               "The ImageView `\(key)` height should have the correct frame height")
                XCTAssertEqual(fixedImageFrame.alignment,
                               value.alignment,
                               "The ImageView `\(key)` frame should have the correct frame alignment")
            }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        settings: DMSuccessViewSettings = DMSuccessDefaultViewSettings()
    ) -> DMSuccessViewTDD {
        let sut = DMSuccessViewTDD(
            settings: settings
        )
        
        return sut
    }
    
}
