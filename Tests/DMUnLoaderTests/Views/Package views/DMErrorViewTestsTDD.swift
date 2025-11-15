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
            .tag(DMErrorViewOwnSettings.imageViewTag)
        
        if let errorText = settingsProvider.errorText {
            Text(errorText)
                .tag(DMErrorViewOwnSettings.errorTextViewTag)
        }
        
        let closeButtonSettings = settingsProvider.actionButtonCloseSettings
        Button(closeButtonSettings.text,
               action: onClose.simpleAction)
        .tag(DMErrorViewOwnSettings.actionButtonCloseViewTag)
    }
}

@MainActor
final class DMErrorViewTestsTDD: XCTestCase {
    
    // MARK: Scenario 1: Verify Default Initialization
    
    func testErrorViewImageCorrespondsToDefaultSettings() throws {
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
    
    func testErrorTextCorrespondsToDefaultSettings() throws {
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
    
    func testErrorTextCorrespondsToAnEmptySettings() throws {
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
            onClose: DMButtonAction { }
        )
        
        // Then
        try verifyThatTheCloseButtonIsPresent(
            sut: sut,
            expectedTextFromSettings: defaultSettings.actionButtonCloseSettings.text,
            expectedTextString: "Close"
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        settings: DMErrorViewSettings,
        onClose: DMAction
    ) -> DMErrorViewTDD {
        let sut = DMErrorViewTDD(
            settings: settings,
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
