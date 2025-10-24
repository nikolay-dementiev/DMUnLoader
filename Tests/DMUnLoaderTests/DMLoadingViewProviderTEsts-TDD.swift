//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI

protocol DMLoadingViewProviderTDD: ObservableObject, Hashable {
    associatedtype LoadingViewType: View
    associatedtype ErrorViewType: View
    associatedtype SuccessViewType: View
    
    func getLoadingView() -> LoadingViewType
    func getErrorView(error: Error, onRetry: DMAction?, onClose: DMAction) -> ErrorViewType
    func getSuccessView(object: DMLoadableTypeSuccess) -> SuccessViewType

    var loadingManagerSettings: DMLoadingManagerSettings { get }
    var loadingViewSettings: DMLoadingViewSettings { get }
    var errorViewSettings: DMErrorViewSettings { get }
    var successViewSettings: DMSuccessViewSettings { get }
}

extension DMLoadingViewProviderTDD {
    static func == (lhs: Self,
                    rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(String.pointer(self))
    }
}

extension DMLoadingViewProviderTDD {
    
    @MainActor
    func getLoadingView() -> some View {
        MockProgressView(settings: loadingViewSettings)
    }
    
    @MainActor
    func getErrorView(error: Error,
                      onRetry: DMAction?,
                      onClose: DMAction) -> some View {
        MockErrorView(settings: errorViewSettings,
                      error: error,
                      onRetry: onRetry,
                      onClose: onClose)
    }
    
    @MainActor
    func getSuccessView(object: DMLoadableTypeSuccess) -> some View {
        MockSuccessView(settings: successViewSettings,
                        assosiatedObject: object)
    }
    
    // MARK: - Default Settings
    
    var loadingManagerSettings: DMLoadingManagerSettings {
        MockDMLoadingManagerSettings()
    }
    
    var loadingViewSettings: DMLoadingViewSettings {
        MockDMLoadingViewSettings()
    }
    
    var errorViewSettings: DMErrorViewSettings {
        MockDMErrorViewSettings()
    }
    
    var successViewSettings: DMSuccessViewSettings {
        MockDMSuccessViewSettings()
    }
}

class DefaultDMLoadingViewProviderTDD: @MainActor DMLoadingViewProviderTDD {
    
}

struct MockProgressView: View {
    let settingsProvider: DMLoadingViewSettings
    
    init(settings settingsProvider: DMLoadingViewSettings) {
        self.settingsProvider = settingsProvider
    }
    
    var body: some View {
        Text("I'm a Progress View Test")
    }
}

struct MockErrorView: View {
    let settingsProvider: DMErrorViewSettings
    let error: Error
    let onRetry: DMAction?
    let onClose: DMAction
    
    init(settings settingsProvider: DMErrorViewSettings,
         error: Error,
         onRetry: DMAction? = nil,
         onClose: DMAction) {
        self.settingsProvider = settingsProvider
        self.error = error
        self.onRetry = onRetry
        self.onClose = onClose
    }
    
    var body: some View {
        Text("I'm a Error View Test")
    }
}

struct MockSuccessView: View {
    let settingsProvider: DMSuccessViewSettings
    let assosiatedObject: DMLoadableTypeSuccess?
    
    init(settings settingsProvider: DMSuccessViewSettings,
         assosiatedObject: DMLoadableTypeSuccess? = nil) {
        self.settingsProvider = settingsProvider
        self.assosiatedObject = assosiatedObject
    }
    
    var body: some View {
        Text("I'm a Success View Test")
    }
}

final class DMLoadingViewProviderTests_TDD: XCTestCase {

    @MainActor
    func testVerifyDefaultInitialization() {
        let sut1 = DefaultDMLoadingViewProviderTDD()
        
        XCTAssertTrue(
            sut1.loadingManagerSettings is MockDMLoadingManagerSettings,
            "Default loadingManagerSettings should be of type MockDMLoadingManagerSettings."
        )
        XCTAssertTrue(
            sut1.loadingViewSettings is MockDMLoadingViewSettings,
            "Default loadingViewSettings should be of type MockDMLoadingViewSettings."
        )
        XCTAssertTrue(
            sut1.errorViewSettings is MockDMErrorViewSettings,
            "Default errorViewSettings should be of type MockDMErrorViewSettings."
        )
        XCTAssertTrue(
            sut1.successViewSettings is MockDMSuccessViewSettings,
            "Default successViewSettings should be of type MockDMSuccessViewSettings."
        )
    }
    
    @MainActor
    func testVerifyHashableConformance() {
        let sut1 = DefaultDMLoadingViewProviderTDD()
        let sut2 = DefaultDMLoadingViewProviderTDD()
        
        XCTAssertNotEqual(sut1, sut2, "Two different instances should have different hash.")
        XCTAssertEqual(sut1, sut1, "Same instance should have different hash.")
    }
}
