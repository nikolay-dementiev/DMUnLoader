//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI
import ViewInspector

struct DMErrorViewTDD: View {
    let settingsProvider: DMErrorViewSettings
    let onRetry: DMAction?
    let onClose: DMAction
    
    init(settings settingsProvider: DMErrorViewSettings,
         onRetry: DMAction? = nil,
         onClose: DMAction) {
        
        self.settingsProvider = settingsProvider
        self.onRetry = onRetry
        self.onClose = onClose
    }
    
    var body: some View {
        let imageSettings = settingsProvider.errorImageSettings
        
        imageSettings.image
            .foregroundStyle(imageSettings.foregroundColor)
            .tag(DMErrorViewOwnSettings.imageViewTag)
        
        if let errorText = settingsProvider.errorText {
            Text(errorText)
                .tag(DMErrorViewOwnSettings.errorTextViewTag)
        }
        
        let closeButtonSettings = settingsProvider.actionButtonCloseSettings
        Button(closeButtonSettings.text,
               action: onClose.simpleAction)
        .tag(DMErrorViewOwnSettings.actionButtonCloseViewTag)
        
        if let onRetry = onRetry {
            let retryButtonSettings = settingsProvider.actionButtonRetrySettings
            
            Button(retryButtonSettings.text,
                   action: onRetry.simpleAction)
            .tag(DMErrorViewOwnSettings.actionButtonRetryViewTag)
        }
    }
}

@MainActor
final class DMErrorViewTestsTDD: XCTestCase {
    
    // MARK: Scenario 1: Verify Default Initialization
    
    func test_ErrorView_ImageCorrespondsTo_DefaultSettings() throws {
        // Given
        let defaultSettings = DMErrorDefaultViewSettings()
        
        // When
        let sut = makeSUT(
            settings: defaultSettings,
            onClose: DMButtonAction { }
        )
        
        // Then
        try checkErrorViewImageCorrespondsToSettings(
            sut: sut,
            expectedImageSettings: defaultSettings.errorImageSettings
        )
    }
    
    func test_ErrorText_CorrespondsTo_DefaultSettings() throws {
        // Given
        let defaultSettings = DMErrorDefaultViewSettings()
        
        // When
        let sut = makeSUT(
            settings: defaultSettings,
            onClose: DMButtonAction { }
        )
        
        // Then
        try checkErrorTextCorrespondsToSettings(
            sut: sut,
            expectedTextFromSettings: defaultSettings.errorText,
            expectedTextString: "An error has occured!"
        )
    }
    
    func test_ErrorText_CorrespondsTo_AnEmpty_Settings() throws {
        // Given
        let defaultSettings = DMErrorDefaultViewSettings()
        
        // When
        let sut = makeSUT(
            settings: defaultSettings,
            onClose: DMButtonAction { }
        )
        
        // Then
        try checkErrorTextCorrespondsToSettings(
            sut: sut,
            expectedTextFromSettings: nil,
            expectedTextString: nil
        )
    }
    
    func testThatThe_CloseButton_IsPresent() throws {
        // Given
        let defaultSettings = DMErrorDefaultViewSettings()
        
        // When
        let sut = makeSUT(
            settings: defaultSettings,
            onClose: DMButtonAction { }
        )
        
        let button = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.actionButtonCloseViewTag)
            .button()
        
        let textOnButton = try button.labelView().text().string()
        
        // Then
        XCTAssertEqual(textOnButton,
                       defaultSettings.actionButtonCloseSettings.text,
                       "The Close Button should display the correct label from settings")
        
        XCTAssertEqual(textOnButton,
                       "Close",
                       "The Close Button should display the correct label: `Close`")
    }
    
    func testThatThe_RetryButton_IsAbsentWhen_OnRetry_IsNotProvided() throws {
        // Given
        let defaultSettings = DMErrorDefaultViewSettings()
        
        // When
        let sut = makeSUT(
            settings: defaultSettings,
            onClose: DMButtonAction { },
            
        )
        let button = try? sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.actionButtonRetryViewTag)
            .button()
        
        // Then
        XCTAssertNil(button, "The Retry Button should not be present")
    }
    
    func testThatThe_RetryButton_IsPresentWhen_OnRetry_IsProvided() throws {
        // Given
        let defaultSettings = DMErrorDefaultViewSettings()
        
        // When
        let sut = makeSUT(
            settings: defaultSettings,
            onRetry: DMButtonAction { },
            onClose: DMButtonAction { }
        )
        let button = try? sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.actionButtonRetryViewTag)
            .button()
        
        // Then
        XCTAssertNotNil(button, "The Retry Button should be present")
    }
    
    // MARK: Scenario 2: Verify Error Image Behavior
    
    func testThatThe_ErrorImage_IsDisplayedWithTheCorrectImage_WithCustomImageSettings() throws {
        // Given
        let errorImage = Image("xmark.octagon")
        let expectedForegroudColor: Color = .orange
        
        let imageSettings = ErrorImageSettings(
            image: errorImage,
            foregroundColor: expectedForegroudColor,
            frameSize: .init(
                width: 60,
                height: 60
            )
        )
        let customSettings = DMErrorDefaultViewSettings(
            errorImageSettings: imageSettings
        )
        
        // When
        let sut = makeSUT(settings: customSettings)
        let imageView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.imageViewTag)
            .image()
        
        // Then
        XCTAssertEqual(
            try imageView.actualImage(),
            errorImage,
            "The image view should display the custom image"
        )
        
        XCTAssertEqual(
            try imageView.foregroundStyleShapeStyle(Color.self),
            expectedForegroudColor,
            "The image view should display the custom image foreground color: `\(expectedForegroudColor)`)`"
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        settings: DMErrorViewSettings,
        onRetry: DMAction? = nil,
        onClose: DMAction = DMButtonAction { }
    ) -> DMErrorViewTDD {
        let sut = DMErrorViewTDD(
            settings: settings,
            onRetry: onRetry,
            onClose: onClose
        )
        
        return sut
    }
    
    private func checkErrorViewImageCorrespondsToSettings(
        sut: DMErrorViewTDD,
        expectedImageSettings: ErrorImageSettings,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        // When
        let image = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.imageViewTag)
            .image()
        
        // Then
        try sutImageNameConfirmToExpectedImage(
            sutImage: image,
            expectedImage: expectedImageSettings.image,
            expectedImageName: "exclamationmark.triangle",
            file: file,
            line: line
        )
    }
    
    private func checkErrorTextCorrespondsToSettings(
        sut: DMErrorViewTDD,
        expectedTextFromSettings: String?,
        expectedTextString: String?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        guard expectedTextFromSettings?.isEmpty == false
                || expectedTextString?.isEmpty == false else {
            return
        }
        
        // When
        let text = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.errorTextViewTag)
            .text()
        
        // Then
        let textFormSUT = try? text.string()
        XCTAssertEqual(textFormSUT,
                       expectedTextFromSettings,
                       "The \(sut.self) text should match the settings",
                       file: file,
                       line: line)
        
        XCTAssertEqual(textFormSUT,
                       expectedTextString,
                       "The \(sut.self) text should match the expected text: `\(String(describing: expectedTextString))`",
                       file: file,
                       line: line)
    }
}
