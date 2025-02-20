//
//  DMErrorHandling
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMErrorHandling
import SwiftUI
import ViewInspector

final class DMErrorViewTests: XCTestCase {
    
    // MARK: Initialization Tests
    
    @MainActor
    func testInitialization() {
        let settingsProvider = MockErrorViewSettingsProvider()
        let error = NSError(domain: "TestError",
                            code: 1,
                            userInfo: nil)
        let onClose = DMButtonAction { }
        let onRetry = DMButtonAction { }
        
        let view = DMErrorView(settings: settingsProvider,
                               error: error,
                               onRetry: onRetry,
                               onClose: onClose)
        
        XCTAssertNotNil(view.settingsProvider,
                        "The settingsProvider should be initialized")
        XCTAssertNotNil(view.error,
                        "The error should be initialized")
        XCTAssertNotNil(view.onClose,
                        "The onClose action should be initialized")
    }
    
    // MARK: Rendering Tests
    
    @MainActor
    func testRendersContainerVStack() throws {
        let settingsProvider = MockErrorViewSettingsProvider()
        let error = NSError(domain: "TestError",
                            code: 1,
                            userInfo: nil)
        let onClose = DMButtonAction { }
        let view = DMErrorView(settings: settingsProvider,
                               error: error,
                               onClose: onClose)
        
        let containerVStack = try view
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.containerVStackViewTag)
            .vStack()
        XCTAssertNotNil(containerVStack,
                        "The container VStack should be rendered")
    }
    
    @MainActor
    func testRendersImageView() throws {
        let settingsProvider = MockErrorViewSettingsProvider()
        let error = NSError(domain: "TestError",
                            code: 1,
                            userInfo: nil)
        let onClose = DMButtonAction { }
        let view = DMErrorView(settings: settingsProvider,
                               error: error,
                               onClose: onClose)
        
        let imageView = try view
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.imageViewTag)
            .image()
        XCTAssertNotNil(imageView,
                        "The ImageView should be rendered")
        
        let imageViewFrame = try? imageView.fixedFrame()
        XCTAssertEqual(imageViewFrame?.width,
                       50,
                       "The ImageView should have the correct frame width")
        XCTAssertEqual(imageViewFrame?.height,
                       50,
                       "The ImageView should have the correct frame height")
        XCTAssertEqual(try imageView.foregroundColor(),
                       .red,
                       "The ImageView should have the correct foreground color")
    }
    
    @MainActor
    func testRendersErrorTextFromProvider() throws {
        let settingsProvider = MockErrorViewSettingsProvider()
        let error = NSError(domain: "TestError",
                            code: 1,
                            userInfo: nil)
        let onClose = DMButtonAction { }
        let view = DMErrorView(settings: settingsProvider,
                               error: error,
                               onClose: onClose)
        
        let errorTextContainerTag = DMErrorViewOwnSettings.errorTextFormProviderContainerViewTag
        let errorTextContainer = try view
            .inspect()
            .find(viewWithTag: errorTextContainerTag)
            .view(DMErrorView.ErrorText.self)
        
        XCTAssertNoThrow(try checkErrorTextContainer(errorTextContainer: errorTextContainer,
                                                     settingsProvider: settingsProvider,
                                                     errorText: settingsProvider.errorText),
                                                  """
                                                  Render ErrorText from exception's text 
                                                 (tag: `\(errorTextContainerTag):\(DMErrorViewOwnSettings.errorTextViewTag)`) 
                                                 should not throw an error
                                                 """)
    }
    
    @MainActor
    func testRendersErrorTextFromException() throws {
        let settingsProvider = MockErrorViewSettingsProvider()
        let error = NSError(domain: "TestError",
                            code: 1,
                            userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
        let onClose = DMButtonAction { }
        let view = DMErrorView(settings: settingsProvider,
                               error: error,
                               onClose: onClose)
        
        let errorTextContainerTag = DMErrorViewOwnSettings.errorTextFormExeptionContainerViewTag
        let errorTextContainer = try view
            .inspect()
            .find(viewWithTag: errorTextContainerTag)
            .view(DMErrorView.ErrorText.self)
        
        XCTAssertNoThrow(try checkErrorTextContainer(errorTextContainer: errorTextContainer,
                                                     settingsProvider: settingsProvider,
                                                     errorText: error.localizedDescription),
                         """
                         Render ErrorText from exception's text 
                        (tag: `\(errorTextContainerTag):\(DMErrorViewOwnSettings.errorTextViewTag)`) 
                        should not throw an error
                        """)
    }
    
    private func checkErrorTextContainer(errorTextContainer: InspectableView<ViewType.View<DMErrorView.ErrorText>>,
                                         settingsProvider: DMErrorViewSettings,
                                         errorText: String?) throws {
        XCTAssertNotNil(errorTextContainer,
                        "The ErrorTextContainer should not be empty")
        
        let errorTextView = try errorTextContainer
            .find(viewWithTag: DMErrorViewOwnSettings.errorTextViewTag)
            .text()
        XCTAssertNotNil(errorTextView,
                        "The ErrorTextView should not be empty")
        
        XCTAssertEqual(try errorTextView.string(),
                       errorText,
                       "The ErrorText should display the correct text from the provider")
        XCTAssertEqual(try errorTextView.attributes().foregroundColor(),
                       settingsProvider.errorTextSettings.foregroundColor,
                       "The ErrorText should have the correct foreground color")
        XCTAssertEqual(try errorTextView.multilineTextAlignment(),
                       settingsProvider.errorTextSettings.multilineTextAlignment,
                        """
                        The ErrorText's multilineTextAlignment should be
                        `\(settingsProvider.errorTextSettings.multilineTextAlignment)`
                        """)
        XCTAssertEqual(try errorTextView.padding(),
                       settingsProvider.errorTextSettings.padding,
                       "The ErrorText's padding should be `\(settingsProvider.errorTextSettings.padding)`")
    }
    
    @MainActor
    func testRendersActionButtonClose() throws {
        let settingsProvider = MockErrorViewSettingsProvider()
        let error = NSError(domain: "TestError",
                            code: 1,
                            userInfo: nil)
        let onClose = DMButtonAction { }
        let view = DMErrorView(settings: settingsProvider,
                               error: error,
                               onClose: onClose)
        
        let containerTag = DMErrorViewOwnSettings.actionButtonCloseViewTag
        let closeButtonContainer = try? view
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.actionButtonCloseViewTag)
            .view(DMErrorView.ActionButton.self)
        
        XCTAssertNoThrow(try checkActionButtonContainer(buttonContainer: closeButtonContainer,
                                                        buttonAction: onClose,
                                                        settingsButtonProvider: settingsProvider.actionButtonCloseSettings),
                         """
                         Render Button from CloseContainer 
                        (tag: `\(containerTag):\(DMErrorViewOwnSettings.actionButtonButtoViewTag)`) 
                        should not throw an error
                        """)
    }
    
    @MainActor
    func testRendersActionButtonRetry() throws {
        let settingsProvider = MockErrorViewSettingsProvider()
        let error = NSError(domain: "TestError",
                            code: 1,
                            userInfo: nil)
        let onClose = DMButtonAction { }
        let onRetry = DMButtonAction { }
        let view = DMErrorView(settings: settingsProvider,
                               error: error,
                               onRetry: onRetry,
                               onClose: onClose)
        
        let containerTag = DMErrorViewOwnSettings.actionButtonRetryViewTag
        let retryButtonContainer = try? view
            .inspect()
            .find(viewWithTag: containerTag)
            .view(DMErrorView.ActionButton.self)
        
        XCTAssertNoThrow(try checkActionButtonContainer(buttonContainer: retryButtonContainer,
                                                        buttonAction: onRetry,
                                                        settingsButtonProvider: settingsProvider.actionButtonRetrySettings),
                         """
                         Render Button from RetryContainer 
                        (tag: `\(containerTag):\(DMErrorViewOwnSettings.actionButtonButtoViewTag)`) 
                        should not throw an error
                        """)
    }
    
    @MainActor
    private func checkActionButtonContainer(buttonContainer: InspectableView<ViewType.View<DMErrorView.ActionButton>>?,
                                            buttonAction: DMAction,
                                            settingsButtonProvider: ActionButtonSettings) throws {
        XCTAssertNotNil(buttonContainer,
                        "The Close Button should exist")
        XCTAssertEqual(buttonAction.id,
                       try buttonContainer?.actualView().action.id,
                       "The Close Button should call the correct action")
        
        let actionButtonView = try buttonContainer?
            .find(viewWithTag: DMErrorViewOwnSettings.actionButtonButtoViewTag)
            .button()
        
        XCTAssertEqual(try actionButtonView?.labelView().text().string(),
                       settingsButtonProvider.text,
                       "The Close Button should display the correct label")
        XCTAssertEqual(try actionButtonView?.background().color().value(),
                       settingsButtonProvider.backgroundColor,
                       "The Close Button should have the correct background color")
        
        XCTAssertEqual(try actionButtonView?.cornerRadius(),
                       settingsButtonProvider.cornerRadius,
                       "The Close Button should have the correct cornerRadius")
        XCTAssertEqual(try actionButtonView?.cornerRadius(),
                       settingsButtonProvider.cornerRadius,
                       "The Close Button should have the correct cornerRadius")
    }
    
    @MainActor
    func testRendersButtonContainersHStack() throws {
        let settingsProvider = MockErrorViewSettingsProvider()
        let error = NSError(domain: "TestError",
                            code: 1,
                            userInfo: nil)
        let onClose = DMButtonAction { }
        let view = DMErrorView(settings: settingsProvider,
                               error: error,
                               onClose: onClose)
        
        // Find the HStack containing buttons by tag
        let hStack = try view
            .inspect()
            .find(viewWithTag: DMErrorViewOwnSettings.buttonContainersHStackViewTag)
            .hStack()
        XCTAssertNotNil(hStack,
                        "The HStack containing buttons should be rendered")
    }
}
