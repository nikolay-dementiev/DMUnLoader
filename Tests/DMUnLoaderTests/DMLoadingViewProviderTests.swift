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
            sut.loadingViewSettings is DMProgressViewDefaultSettings,
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
        
        let settings = loadingView?.settingsProvider as? DMProgressViewDefaultSettings
        XCTAssertNotNil(
            settings,
            "Loading view settings should be of type DMLoadingDefaultViewSettings.",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            settings,
            sut.loadingViewSettings as? DMProgressViewDefaultSettings,
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
            private(set) var loadingViewRequests = 0
            private(set) var errorViewRequests = 0
            private(set) var successViewRequests = 0
            
            @MainActor
            func getLoadingView() -> some View {
                loadingViewRequests += 1
                return MockDMSuccessViewTest()
            }
            
            @MainActor
            func getErrorView(error: any Error,
                              onRetry: (any DMAction)?,
                              onClose: any DMAction) -> some View {
                errorViewRequests += 1
                return MockDMErrorViewTest()
            }
            
            @MainActor
            func getSuccessView(object: any DMLoadableTypeSuccess) -> some View {
                successViewRequests += 1
                return MockDMSuccessViewTest()
            }
        }
        
        let custom = CustomProvider()
        // A loading state holds the erased provider, so every request must reach the custom one.
        let provider = custom.eraseToAnyViewProvider()
        
        _ = provider.getLoadingView()
        _ = provider.getErrorView(error: NSError(domain: "TestError", code: 1, userInfo: nil),
                                  onRetry: nil,
                                  onClose: DMButtonAction({}))
        _ = provider.getSuccessView(object: StubDMLoadableTypeSuccess())
        
        XCTAssertEqual(custom.loadingViewRequests, 1, "the erased provider asks the custom provider for the loading view")
        XCTAssertEqual(custom.errorViewRequests, 1, "the erased provider asks the custom provider for the error view")
        XCTAssertEqual(custom.successViewRequests, 1, "the erased provider asks the custom provider for the success view")
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
