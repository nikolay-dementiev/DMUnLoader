//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUICore

final class DMLoadingViewProviderUseCaseTests: XCTestCase {
    
    @MainActor
    func test_defaultImplementation_providesCorrectLoadingView() {
        
        let sut = makeSUT()
        let loadingView = sut.getLoadingView()
        
        let progressView = loadingView as? DMProgressView
        XCTAssertNotNil(progressView, "The loading view should be a DMProgressView instance")
        
        XCTAssertEqual(
            progressView?.settingsProvider as? DMLoadingDefaultViewSettings,
            DMLoadingDefaultViewSettings(),
            "The view settings should match the default settings"
        )
    }
    
    @MainActor
    func test_defaultImplementation_providesCorrectErrorView() {
        
        let testError = anyDomainNSError()
        let retryAction = DMButtonAction {}
        let closeAction = DMButtonAction {}
        let sut = makeSUT()
        
        let errorView = sut.getErrorView(
            error: testError,
            onRetry: retryAction,
            onClose: closeAction
        ) as? DMErrorView
        
        XCTAssertNotNil(errorView, "The returned view should be of type `DMErrorView`")
        XCTAssertTrue((errorView?.error as? NSError) == testError, "The error should match the provided error")
        XCTAssertEqual(errorView?.onRetry?.id, retryAction.id, "The retry action `id` should match")
        XCTAssertEqual(errorView?.onClose.id, closeAction.id, "The close action `id` should match")
        XCTAssertEqual(
            errorView?.settingsProvider as? DMErrorDefaultViewSettings,
            DMErrorDefaultViewSettings(),
            "The view settings should match the default settings"
        )
    }
    
    @MainActor
    func test_defaultImplementation_providesCorrectSuccessView() {
        
        let sut = makeSUT()
        let successMessage = "Operation Completed!"
        
        let successView = sut.getSuccessView(object: successMessage)as? DMSuccessView
        
        XCTAssertNotNil(successView, "The returned view should be of type DMSuccessView")
        XCTAssertEqual(
            successView?.assosiatedObject as? String,
            successMessage,
            "The success message should match the provided message"
        )
        XCTAssertEqual(
            successView?.settingsProvider as? DMSuccessDefaultViewSettings,
            DMSuccessDefaultViewSettings(),
            "The view settings should match the default settings"
        )
    }

    func test_defaultImplementation_providesUniqueID() {
        let sut1 = makeSUT()
        let sut2 = makeSUT()
        
        XCTAssertNotEqual(sut1.id, sut2.id, "Each LoadingViewProvider instance should have a unique ID")
    }
    
    // MARK: Settings
    func test_defaultImplementation_providesLoadingManagerSettings() {
        let sut = makeSUT()
        
        let settingsUT = sut.loadingManagerSettings
        let defaultSettings = DMLoadingManagerConfiguration.Settings.self
        XCTAssertEqual(settingsUT.autoHideDelay, defaultSettings.autoHideDelay)
    }
    
    func test_defaultImplementation_providesLoadingViewSettings() {
        let sut = makeSUT()
        
        let settingsUT = sut.loadingViewSettings
        let defaultSettings = DMLoadingDefaultViewSettings.Settings.self
        XCTAssertEqual(
            settingsUT.frameGeometrySize,
            defaultSettings.frameGeometrySize
        )
        XCTAssertEqual(
            settingsUT.loadingContainerForegroundColor,
            .primary
        )
        XCTAssertEqual(
            settingsUT.progressIndicatorProperties,
            defaultSettings.progressIndicatorProperties
        )
        XCTAssertEqual(
            settingsUT.loadingTextProperties,
            defaultSettings.loadingTextProperties
        )
    }
    
    func test_defaultImplementation_providesErrorViewSettings() {
        let sut = makeSUT()
        
        let settingsUT = sut.errorViewSettings
        let defaultSettings = DMErrorDefaultViewSettings.Settings.self
        XCTAssertEqual(
            settingsUT.errorText,
            defaultSettings.errorText
        )
        XCTAssertEqual(
            settingsUT.errorTextSettings,
            defaultSettings.errorTextSettings
        )
        XCTAssertEqual(
            settingsUT.actionButtonCloseSettings,
            defaultSettings.actionButtonCloseSettings
        )
        XCTAssertEqual(
            settingsUT.actionButtonRetrySettings,
            defaultSettings.actionButtonRetrySettings
        )
        XCTAssertEqual(
            settingsUT.errorImageSettings,
            defaultSettings.errorImageSettings
        )
    }
    
    func test_defaultImplementation_providesSuccessViewSettings() {
        let sut = makeSUT()
        
        let settingsUT = sut.successViewSettings
        let defaultSettings = DMSuccessDefaultViewSettings.Settings.self
        
        XCTAssertEqual(
            settingsUT.successImageProperties,
            defaultSettings.successImageProperties
        )
        XCTAssertEqual(
            settingsUT.successTextProperties,
            defaultSettings.successTextProperties
        )
    }
    
    // MARK: - Helpers
    private func makeSUT() -> any DMLoadingViewProvider {
        LoadingViewProviderSpyDecorator(decoratee: DefaultDMLoadingViewProvider())
    }
    
    private func anyDomainNSError() -> NSError {
        NSError(domain: "TestDomain", code: 404, userInfo: nil)
    }
}

// MARK: - Spy

private final class LoadingViewProviderSpyDecorator: DMLoadingViewProvider {
    var id: UUID {
        object.id
    }
    
    let object: any DMLoadingViewProvider
    
    init(decoratee object: some DMLoadingViewProvider) {
        self.object = object
    }
}
