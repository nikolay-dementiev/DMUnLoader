//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import SwiftUI
import ViewInspector

struct DMProgressViewTDD: View {
    let settingsProvider: DMProgressViewSettings
    
    init(settings settingsProvider: DMProgressViewSettings) {
        self.settingsProvider = settingsProvider
    }
    
    var body: some View {
        let loadingTextProperties = settingsProvider.loadingTextProperties
        let progressIndicatorProperties = settingsProvider.progressIndicatorProperties
        
        ZStack(alignment: .center) {
            
            let minSize: CGFloat = 30
            VStack {
                Text(loadingTextProperties.text)
                    .tag(DMProgressViewOwnSettings.textTag)
                
                ProgressView()
                    .controlSize(progressIndicatorProperties.size)
                    .progressViewStyle(.circular)
                    .tag(DMProgressViewOwnSettings.progressViewTag)
            }
            .frame(minWidth: minSize,
                   maxWidth: 150,
                   minHeight: minSize,
                   maxHeight: 300)
            .fixedSize()
        }
    }
}

final class DMProgressViewTests_TDD: XCTestCase {
    
    // MARK: Scenario 1: Verify Default Initialization
    
    @MainActor
    func testThatViewConfirmToViewProtocol() {
        let sut = makeSUT()
        XCTAssertTrue((sut as Any) is (any View), "DMProgressView should conform to View protocol")
    }
    
    @MainActor
    func testThatTextIsDisplayed() throws {
        let settings = DMProgressViewDefaultSettings()
        let sut = makeSUT(settings: settings)
        
        let text = try sut
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.textTag)
            .text()
            .string()
        
        XCTAssertEqual(text,
                       settings.loadingTextProperties.text,
                       "The Text view should display the correct text")
        
        XCTAssertEqual(text,
                       "Loading...",
                       "The Text view should display the correct text")
    }
    
    @MainActor
    func testThatProgressIndicatorIsDisplayed() throws {
        let settings = DMProgressViewDefaultSettings()
        let sut = makeSUT(settings: settings)
        
        let progressView = try sut
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.progressViewTag)
            .progressView()
        XCTAssertNotNil(progressView,
                        "The ProgressView should be rendered")
    }
    
    // MARK: - Helpers
    
    @MainActor
    private func makeSUT(
        settings: DMProgressViewSettings = MockDMProgressViewSettings()
    ) -> DMProgressViewTDD {
        DMProgressViewTDD(settings: settings)
    }
}
