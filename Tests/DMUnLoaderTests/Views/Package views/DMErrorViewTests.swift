//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//
// swiftlint:disable file_length

import XCTest
@testable import DMUnLoader
import SwiftUI
import ViewInspector
import SnapshotTesting

@MainActor
// swiftlint:disable:next type_body_length
final class DMErrorViewTests: XCTestCase {
    
    override func invokeTest() {
        withSnapshotTesting(
            record: .missing,
            diffTool: .ksdiff
        ) {
            super.invokeTest()
        }
    }
    
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
    
    func testThatThe_ErrorImage_IsDisplayedWithTheCorrectImage() throws {
        // Given
        let imageSettings = makeCustomImageSettingsForScenario2()
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
            imageSettings.image
                .resizable(),
            "The image view should display the custom image"
        )
    }
    
    func testThatThe_ErrorImage_ForegroundColor_CorresponsToSettings() throws {
        // Given
        let imageSettings = makeCustomImageSettingsForScenario2()
        let customSettings = DMErrorDefaultViewSettings(
            errorImageSettings: imageSettings
        )
        let expectedForegroudColor = customSettings.errorImageSettings.foregroundColor
        
        // When
        let sut = makeSUT(settings: customSettings)
        let imageView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.imageViewTag)
            .image()
        
        // Then
        XCTAssertEqual(
            try imageView.foregroundStyleShapeStyle(Color.self),
            customSettings.errorImageSettings.foregroundColor,
            "The image view should display the custom image foreground color: `\(String(describing: expectedForegroudColor))`)`"
        )
    }
    
    func testThatThe_ErrorImage_FrameSize_CorresponsToSettings() throws {
        // Given
        let imageSettings = makeCustomImageSettingsForScenario2()
        let customSettings = DMErrorDefaultViewSettings(
            errorImageSettings: imageSettings
        )
        let expectedFrameSize = customSettings.errorImageSettings.frameSize
        
        // When
        let sut = makeSUT(settings: customSettings)
        let imageView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.imageViewTag)
            .image()
        
        // Then
        XCTAssertEqual(
            try imageView.fixedFrame().width,
            expectedFrameSize.width,
            "The image view should have the correct width from settings: `\(String(describing: expectedFrameSize.width))`"
        )
        
        XCTAssertEqual(
            try imageView.fixedFrame().height,
            expectedFrameSize.height,
            "The image view should have the correct height from settings: `\(String(describing: expectedFrameSize.height))`"
        )
    }
    
    func testThatThe_ErrorImage_Aligment_CorresponsToSettings() throws {
        // Given
        let imageSettings = makeCustomImageSettingsForScenario2()
        let customSettings = DMErrorDefaultViewSettings(
            errorImageSettings: imageSettings
        )
        let expectedAlignment = customSettings.errorImageSettings.frameSize.alignment
        
        // When
        let sut = makeSUT(settings: customSettings)
        let imageView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.imageViewTag)
            .image()
        
        // Then
        XCTAssertEqual(
            try imageView.fixedAlignment(),
            expectedAlignment,
            "The image view should have the correct alignment from settings: `\(String(describing: expectedAlignment))`"
        )
    }
    
    func testThatThe_ErrorImage_ResizableParameters_ConfirmToExpectedDefault() throws {
        // Given
        let imageSettings = makeCustomImageSettingsForScenario2()
        let customSettings = DMErrorDefaultViewSettings(
            errorImageSettings: imageSettings
        )
        
        // When
        let sut = makeSUT(settings: customSettings)
        let imageView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.imageViewTag)
            .image()
        let resizableParameters = try imageView.actualImage().resizableParameters()
        
        // Then
        XCTAssertEqual(
            resizableParameters.capInsets,
            EdgeInsets(),
            "The resizable image capInsets should be equal to EdgeInsets()"
        )
        XCTAssertEqual(
            resizableParameters.resizingMode,
            .stretch,
            "The resizable image resizingMode should be .stretch"
        )
    }
    
    // MARK: Scenario 3: Verify Error Title Behavior
    
    func testThatThe_TitleErrorText_IsDisplayedWithThe_Text_BasedOnSetings() throws {
        // Given
        let customSettings = makeCustomSettingsForScenario3And4()
        
        // When
        let sut = makeSUT(settings: customSettings)
        let errorTextView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.errorTextViewTag)
            .text()
        
        // Then
        XCTAssertEqual(
            try errorTextView.string(),
            customSettings.errorText,
            """
            The error text view should display the custom error title
            text from settings: `\(String(describing: customSettings.errorText))`
            """
        )
    }
    
    func testThatThe_TitleErrorText_IsDisplayedWithThe_ForegroundColor_BasedOnSetings() throws {
        // Given
        let customSettings = makeCustomSettingsForScenario3And4()
        
        // When
        let sut = makeSUT(settings: customSettings)
        let errorTextView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.errorTextViewTag)
            .text()
        
        // Then
        XCTAssertEqual(
            try errorTextView.foregroundStyleShapeStyle(Color.self),
            customSettings.errorTextSettings.foregroundColor,
            """
            The title error text view should display the custom foreground color 
            from settings: `\(String(describing: customSettings.errorTextSettings.foregroundColor))`
            """
        )
    }
    
    func testThatThe_TitleErrorText_IsDisplayedWithThe_Alignment_BasedOnSetings() throws {
        // Given
        let customSettings = makeCustomSettingsForScenario3And4()
        
        // When
        let sut = makeSUT(settings: customSettings)
        let errorTextView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.errorTextViewTag)
            .text()
        
        // Then
        XCTAssertEqual(
            try errorTextView.multilineTextAlignment(),
            customSettings.errorTextSettings.multilineTextAlignment,
            """
            The title error text view should display the custom alignment from settings: 
            `\(String(describing: customSettings.errorTextSettings.multilineTextAlignment))`
            """
        )
    }
    
    func testThatThe_TitleErrorText_IsDisplayedWithThe_Padding_BasedOnSetings() throws {
        // Given
        let customSettings = makeCustomSettingsForScenario3And4()
        
        // When
        let sut = makeSUT(settings: customSettings)
        let errorTextView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.errorTextViewTag)
            .text()
        
        // Then
        XCTAssertEqual(
            try errorTextView.padding(),
            customSettings.errorTextSettings.padding,
            """
            The title error text view should display the custom padding from settings:
            `\(String(describing: customSettings.errorTextSettings.padding))`
            """
        )
    }
    
    // MARK: Scenario 4: Verify Error Behavior
    
    func testThatThe_Error_IsDisplayedWithThe_Text_BasedOnSetings() throws {
        // Given
        let customSettings = makeCustomSettingsForScenario3And4()
        let error = makeNSErrorForScenario4()
        
        // When
        let sut = makeSUT(
            settings: customSettings,
            error: error
        )
        let errorTextView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.errorTextFormExeptionContainerViewTag)
            .text()
        
        // Then
        XCTAssertEqual(
            try errorTextView.string(),
            error.localizedDescription,
            """
            The exeption error text view should display the custom error
            text from the view's error: `\(String(describing: error.localizedDescription))`
            """
        )
    }
    
    func testThatThe_Error_IsDisplayedWithThe_TitleText_BasedOnSetings() throws {
        // Given
        let customSettings = makeCustomSettingsForScenario3And4()
        let error = makeNSErrorForScenario4()
        
        // When
        let sut = makeSUT(
            settings: customSettings,
            error: error
        )
        let errorTitleTextView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.errorTextViewTag)
            .text()
        
        // Then
        XCTAssertEqual(
            try errorTitleTextView.string(),
            customSettings.errorText,
            """
            The exeption error text view should display the custom error
            text from settings: `\(String(describing: customSettings.errorText))`
            """
        )
    }
    
    func testThatThe_Error_IsDisplayedWithThe_ForegroundColor_BasedOnSetings() throws {
        // Given
        let customSettings = makeCustomSettingsForScenario3And4()
        let error = makeNSErrorForScenario4()
        
        // When
        let sut = makeSUT(
            settings: customSettings,
            error: error
        )
        let errorTextView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.errorTextFormExeptionContainerViewTag)
            .text()
        
        // Then
        XCTAssertEqual(
            try errorTextView.foregroundStyleShapeStyle(Color.self),
            customSettings.errorTextSettings.foregroundColor,
                """
                The error text view should display the custom foreground color 
                from settings: `\(String(describing: customSettings.errorTextSettings.foregroundColor))`
                """
        )
    }
    
    func testThatThe_Error_IsDisplayedWithThe_Alignment_BasedOnSetings() throws {
        // Given
        let customSettings = makeCustomSettingsForScenario3And4()
        let error = makeNSErrorForScenario4()
        
        // When
        let sut = makeSUT(
            settings: customSettings,
            error: error
        )
        let errorTextView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.errorTextFormExeptionContainerViewTag)
            .text()
        
        // Then
        XCTAssertEqual(
            try errorTextView.multilineTextAlignment(),
            customSettings.errorTextSettings.multilineTextAlignment,
            """
            The error text view should display the custom alignment from settings: 
            `\(String(describing: customSettings.errorTextSettings.multilineTextAlignment))`
            """
        )
    }
    
    func testThatThe_ErrorText_IsDisplayedWithThe_Padding_BasedOnSetings() throws {
        // Given
        let customSettings = makeCustomSettingsForScenario3And4()
        let error = makeNSErrorForScenario4()
        
        // When
        let sut = makeSUT(
            settings: customSettings,
            error: error
        )
        let errorTextView = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.errorTextFormExeptionContainerViewTag)
            .text()
        
        // Then
        XCTAssertEqual(
            try errorTextView.padding(),
            customSettings.errorTextSettings.padding,
            """
            The error text view should display the custom padding from settings:
            `\(String(describing: customSettings.errorTextSettings.padding))`
            """
        )
    }
    
    // MARK: Scenario 5: Verify Action Buttons Behavior
    
    func testThatThe_CloseButton_IsDisplayedWithThe_Text_BasedOnSetings() throws {
        // Given
        let customSettings = makeCustomSettingsForActionButton()

        // When
        let sut = makeSUT(
            settings: customSettings,
            onClose: DMButtonAction { }
        )
        let closeButton = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.actionButtonCloseViewTag)
            .button()
        
        // Then
        XCTAssertEqual(
            try closeButton.labelView().text().string(),
            customSettings.actionButtonCloseSettings.text,
            "The close button should display the custom text from settings: `\(customSettings.actionButtonCloseSettings.text)`"
            )
    }
    
    func testThatThe_RetryButton_IsNOTDisplayed_When_OnRetryAction_DoesNotProvided() throws {
        // Given
        let customSettings = makeCustomSettingsForActionButton()

        // When
        let sut = makeSUT(
            settings: customSettings,
            onClose: DMButtonAction { }
        )
        let retryButton = try? sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.actionButtonRetryViewTag)
            .button()
        
        // Then
        XCTAssertNil(retryButton,
                     "The retry button should NOT be displayed when onRetry action is not provided")
    }
    
    func testThatThe_ViewWithCloseButton_IsStyledCorrectlyAccordingToSettings() throws {
        // Given
        let customSettings = makeCustomSettingsForActionButton(errorText: "")
        
        // When
        let sut = makeSUT(
            settings: customSettings,
            error: DMAppError.custom(nil),
            onClose: DMButtonAction { }
        )
        
        // Then
        assertSnapshot(
            of: LoadingViewContainer<DMErrorView>(overlayView: { sut }),
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .light)
            ),
            named: "ViewWith-CloseButton-iPhone13Pro-light"
        )
    }
    
    func testThatThe_RetryButton_IsDisplayedWithThe_Text_BasedOnSetings_When_OnRetry_IsProvided() throws {
        // Given
        let customSettings = makeCustomSettingsForActionButton()

        // When
        let sut = makeSUT(
            settings: customSettings,
            onRetry: DMButtonAction { },
        )
        let retryButton = try sut
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.actionButtonRetryViewTag)
            .button()
        
        // Then
        XCTAssertEqual(
            try retryButton.labelView().text().string(),
            customSettings.actionButtonRetrySettings.text,
            "The retry button should display the custom text from settings: `\(customSettings.actionButtonRetrySettings.text)`"
            )
    }
    
    func testThatThe_ViewWithRetryButton_IsStyledCorrectlyAccordingToSettings() throws {
        // Given
        let customSettings = makeCustomSettingsForActionButton(errorText: "")
        
        // When
        let sut = makeSUT(
            settings: customSettings,
            error: DMAppError.custom(nil),
            onRetry: DMButtonAction { },
        )
        guard let sutInspection = sut.inspection else {
            XCTFail("Inspection not available on SUT")
            return
        }
        
        let expInspection = sutInspection.inspect { view in
            let updatedView = try XCTUnwrap(
                try view.actualView(),
                "Failed to extract the actual view from the inspect"
            )
            assertSnapshot(
                of: LoadingViewContainer<DMErrorView>(overlayView: { updatedView }),
                as: .image(
                    layout: .device(config: .iPhone13Pro),
                    traits: .init(userInterfaceStyle: .light)
                ),
                named: "ViewWith-RetryButton-iPhone13Pro-light"
            )
        }
        
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        
        // Then
        wait(for: [expInspection], timeout: 0.05)
    }
    
    func testThat_TapOnTheCloseButton_Trigger_OnCloseAction() throws {
        // Given
        let customSettings = makeCustomSettingsForActionButton()
        let buttonTapExp = expectation(description: "Close button tap action triggered")
        
        // When
        let sut = makeSUT(
            settings: customSettings,
            onClose: DMButtonAction {
                buttonTapExp.fulfill()
            }
        )
        
        guard let sutInspection = sut.inspection else {
            XCTFail("Inspection not available on SUT")
            return
        }
        
        let expInspection = sutInspection.inspect { view in
            try view
                .find(viewWithTag: DMErrorViewOwnSettings.actionButtonCloseViewTag)
                .button()
                .tap()
        }
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        
        // Then
        wait(for: [expInspection], timeout: 0.05)
        wait(for: [buttonTapExp], timeout: 0.055)
    }
    
    func testThatTap_OnTheRetryButton_Trigger_OnRetryAction() throws {
        // Given
        let customSettings = makeCustomSettingsForActionButton()
        let buttonTapExp = expectation(description: "Retry button tap action triggered")
        
        // When
        let sut = makeSUT(
            settings: customSettings,
            onRetry: DMButtonAction {
                buttonTapExp.fulfill()
            }
        )
        
        guard let sutInspection = sut.inspection else {
            XCTFail("Inspection not available on SUT")
            return
        }
        
        let expInspection = sutInspection.inspect { view in
            try view
                .find(viewWithTag: DMErrorViewOwnSettings.actionButtonRetryViewTag)
                .button()
                .tap()
        }
        ViewHosting.host(view: sut)
        defer { ViewHosting.expel() }
        
        // Then
        wait(for: [expInspection], timeout: 0.05)
        wait(for: [buttonTapExp], timeout: 0.055)
    }
    
    // MARK: Scenario 6: Verify Snapshot Testing
    
    func testThat_ErrorView_Renders_Correctly_When_DefaultSettings_Provided() throws {
        // Given
        let defaultSettings = DMErrorDefaultViewSettings()
        
        // When
        let sut = makeSUT(
            settings: defaultSettings
        )
        
        // Then
        assertSnapshot(
            of: LoadingViewContainer<DMErrorView>(overlayView: { sut }),
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .light)
            ),
            named: "DefaultSettings-iPhone13Pro-light"
        )
        assertSnapshot(
            of: LoadingViewContainer<DMErrorView>(overlayView: { sut }),
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .dark)
            ),
            named: "DefaultSettings-iPhone13Pro-dark"
        )
    }
    
    func testThat_ErrorView_Renders_Correctly_When_CustomSettings_Provided() throws {
        // Given
        let customSettings = DMErrorDefaultViewSettings(
            errorText: "Oops! Looks like something went wrong...",
            actionButtonCloseSettings: ActionButtonSettings(
                text: "X"
            ),
            actionButtonRetrySettings: ActionButtonSettings(
                text: "Try Again"
            ),
            errorTextSettings: ErrorTextSettings(
                foregroundColor: Color.mint,
                multilineTextAlignment: .leading,
                padding: EdgeInsets(
                    top: 11,
                    leading: 16,
                    bottom: 12,
                    trailing: 17
                    )
                ),
            errorImageSettings: ErrorImageSettings(
                image: Image(systemName: "exclamationmark.triangle"),
                foregroundColor: Color.orange,
                frameSize: CustomViewSize(
                    width: 54,
                    height: 54,
                    alignment: .bottomTrailing
                )
            )
        )
        
        // When
        let sut = makeSUT(
            settings: customSettings,
            onRetry: DMButtonAction {},
        )
        
        // Then
        assertSnapshot(
            of: LoadingViewContainer<DMErrorView>(overlayView: { sut }),
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .light)
            ),
            named: "CustomSettingsSettings-iPhone13Pro-light"
        )
        assertSnapshot(
            of: LoadingViewContainer<DMErrorView>(overlayView: { sut }),
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: .init(userInterfaceStyle: .dark)
            ),
            named: "CustomSettingsSettings-iPhone13Pro-dark"
        )
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        settings: DMErrorViewSettings,
        error: Error = NSError(domain: "TestErrorDomain", code: 1, userInfo: nil),
        onRetry: DMAction? = nil,
        onClose: DMAction = DMButtonAction { }
    ) -> DMErrorView {
        let sut = DMErrorView(
            settings: settings,
            error: error,
            onRetry: onRetry,
            onClose: onClose
        )
        
        return sut
    }
    
    private func checkErrorViewImageCorrespondsToSettings(
        sut: DMErrorView,
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
        sut: DMErrorView,
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
    
    private func makeCustomImageSettingsForScenario2() -> ErrorImageSettings {
        let errorImage = Image("xmark.octagon")
        let expectedForegroudColor = Color.orange
        let expectedFrameSize = CustomViewSize(
            width: 60,
            height: 60,
            alignment: .bottomTrailing
        )
        
        let imageSettings = ErrorImageSettings(
            image: errorImage,
            foregroundColor: expectedForegroudColor,
            frameSize: expectedFrameSize
        )
        
        return imageSettings
    }
    
    private func makeCustomSettingsForScenario3And4() -> DMErrorDefaultViewSettings {
        let textSettings = ErrorTextSettings(
            foregroundColor: Color.red,
            multilineTextAlignment: .leading,
            padding: EdgeInsets(
                top: 11,
                leading: 16,
                bottom: 12,
                trailing: 17
            )
        )
        
        return DMErrorDefaultViewSettings(
            errorText: "Oops! Something went wrong.",
            errorTextSettings: textSettings,
        )
    }
    
    private func makeCustomSettingsForActionButton(errorText: String? = nil) -> DMErrorDefaultViewSettings {
        DMErrorDefaultViewSettings(
            errorText: errorText,
            actionButtonCloseSettings: ActionButtonSettings(
                text: "Dismiss"
            ),
            actionButtonRetrySettings: ActionButtonSettings(
                text: "Try Again"
            )
        )
    }
    
    private func makeNSErrorForScenario4() -> NSError {
        NSError(
            domain: "TestError",
            code: 1404,
            userInfo: [NSLocalizedDescriptionKey: "Something went wrong"]
        )
    }
}
