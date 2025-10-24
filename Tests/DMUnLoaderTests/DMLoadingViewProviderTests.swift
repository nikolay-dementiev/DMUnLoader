//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI

final class DMLoadingViewProviderTests: XCTestCase {
    
    @MainActor
    func testVerifyDefaultInitialization() {
        let sut = DefaultDMLoadingViewProvider()
        
        XCTAssertTrue(
            sut.loadingManagerSettings is DMLoadingManagerDefaultSettings,
            "Default loadingManagerSettings should be of type DMLoadingManagerDefaultSettings."
        )
        XCTAssertTrue(
            sut.loadingViewSettings is DMLoadingDefaultViewSettings,
            "Default loadingViewSettings should be of type DMLoadingDefaultViewSettings."
        )
        XCTAssertTrue(
            sut.errorViewSettings is DMErrorDefaultViewSettings,
            "Default errorViewSettings should be of type DMErrorDefaultViewSettings."
        )
        XCTAssertTrue(
            sut.successViewSettings is DMSuccessDefaultViewSettings,
            "Default successViewSettings should be of type DMSuccessDefaultViewSettings."
        )
    }
    
    @MainActor
    func testVerifyHashableConformance() {
        let sut1 = DefaultDMLoadingViewProvider()
        let sut2 = DefaultDMLoadingViewProvider()
        
        XCTAssertNotEqual(sut1, sut2, "Two different instances should have different hash.")
        XCTAssertEqual(sut1, sut1, "Same instance should have different hash.")
    }
    
    @MainActor
    func testVerifyCustomizationViaSettings() {
        let sut = DefaultDMLoadingViewProvider()
        
        checkVerifyCustomizationViaSettingsForProgressView(sut: sut)
        checkVerifyCustomizationViaSettingsForErrorView(sut: sut)
        checkVerifyCustomizationViaSettingsForSuccessView(sut: sut)
    }
    
    @MainActor
    private func checkVerifyCustomizationViaSettingsForProgressView<SUT: DMLoadingViewProvider>(
        sut: SUT,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let loadingView = sut.getLoadingView() as? DMProgressView
        XCTAssertNotNil(
            loadingView,
            "Loading view should be of type DMProgressView.",
            file: file,
            line: line
        )
        
        let settings = loadingView?.settingsProvider as? DMLoadingDefaultViewSettings
        XCTAssertNotNil(
            settings,
            "Loading view settings should be of type DMLoadingDefaultViewSettings.",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            settings,
            sut.loadingViewSettings as? DMLoadingDefaultViewSettings,
            "Loading view settings should match the provider's loadingViewSettings.",
            file: file,
            line: line
        )
    }
    
    @MainActor
    private func checkVerifyCustomizationViaSettingsForErrorView<SUT: DMLoadingViewProvider>(
        sut: SUT,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let errorView = sut.getErrorView(
            error: NSError(domain: "Test", code: 404),
            onRetry: nil,
            onClose: DMButtonAction {}
        ) as? DMErrorView
        
        XCTAssertNotNil(
            errorView,
            "Error view should be of type DMErrorView.",
            file: file,
            line: line
        )
        
        let settingsFromView = errorView?.settingsProvider as? DMErrorDefaultViewSettings
        XCTAssertNotNil(
            settingsFromView,
            "Error view settings should be of type DMErrorDefaultViewSettings.",
            file: file,
            line: line
        )
        let settingsFromProvider = sut.errorViewSettings as? DMErrorDefaultViewSettings
        XCTAssertNotNil(
            settingsFromProvider,
            "Error view settings from provider should be of type DMErrorDefaultViewSettings.",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            settingsFromView,
            settingsFromProvider,
            "Error view settings should match the provider's errorViewSettings.",
            file: file,
            line: line
        )
    }
    
    @MainActor
    private func checkVerifyCustomizationViaSettingsForSuccessView<SUT: DMLoadingViewProvider>(
        sut: SUT,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let successView = sut.getSuccessView(object: "Some object") as? DMSuccessView
        
        XCTAssertNotNil(
            successView,
            "Success view should be of type DMSuccessView.",
            file: file,
            line: line
        )
        
        let settingsFromView = successView?.settingsProvider as? DMSuccessDefaultViewSettings
        XCTAssertNotNil(
            settingsFromView,
            "Success view settings should be of type DMSuccessDefaultViewSettings.",
            file: file,
            line: line
        )
        let settingsFromProvider = sut.successViewSettings as? DMSuccessDefaultViewSettings
        XCTAssertNotNil(
            settingsFromProvider,
            "Success view settings from provider should be of type DMSuccessDefaultViewSettings.",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            settingsFromView,
            settingsFromProvider,
            "Success view settings should match the provider's successViewSettings.",
            file: file,
            line: line
        )
    }
    
    @MainActor
    func testCustomImplementation() throws {
        final class CustomProvider: DMLoadingViewProvider {
            let id = UUID()
            
            @MainActor
            func getLoadingView() -> some View {
                MockDMSuccessViewTest()
            }
            
            @MainActor
            func getErrorView(error: Error,
                              onRetry: DMAction?,
                              onClose: DMAction) -> some View {
                MockDMErrorViewTest()
            }
            
            @MainActor
            func getSuccessView(object: DMLoadableTypeSuccess) -> some View {
                MockDMSuccessViewTest()
            }
        }
        
        let provider = CustomProvider()
        
        let loadingView: MockDMSuccessViewTest = try castView(provider
            .getLoadingView()
        )
        let errorView: MockDMErrorViewTest = try castView(provider
            .getErrorView(error: NSError(domain: "TestError",
                                         code: 1,
                                         userInfo: nil),
                          onRetry: nil,
                          onClose: DMButtonAction({}))
        )
        
        let successView: MockDMSuccessViewTest = try castView(provider
            .getSuccessView(object: MockDMLoadableTypeSuccess())
        )
        
        XCTAssertTrue((loadingView as Any) is MockDMSuccessViewTest,
                      "Custom loading view should be an instance of Text")
        XCTAssertTrue((errorView as Any) is MockDMErrorViewTest,
                      "Custom error view should be an instance of Image")
        XCTAssertTrue((successView as Any) is MockDMSuccessViewTest,
                      "Custom success view should be an instance of Text")
    }
    
    // MARK: - Helpers
    
    func castView<T: View>(_ viewToCast: some View) throws -> T {
        
        guard let viewToCast = viewToCast as? T else {
            let requestedView = try viewToCast
                .inspect()
                .view(T.self)
                .actualView()
            
            return requestedView
        }
        
        return viewToCast
    }
}
