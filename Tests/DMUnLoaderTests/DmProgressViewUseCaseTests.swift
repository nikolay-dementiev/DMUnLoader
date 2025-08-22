//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import ViewInspector
@testable import DMUnLoader

@MainActor
final class DmProgressViewUseCaseTests: XCTestCase {

    func test_progressView_VerifyDefaultInitialization_viewContainsProgressView() throws {
        
        let sut = makeSUT()
        
        let progressView = try sut
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.progressViewTag)
            .progressView()
        XCTAssertNotNil(progressView,
                        "The ProgressView should be rendered")
    }
    
    func test_progressView_VerifyDefaultInitialization_ProgressViewDefaultTextIsCorrect() throws {
        let sut = makeSUT()
        
        let text = try sut
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.textTag)
            .text()
        XCTAssertEqual(try text.string(),
                       "Loading...",
                       "The Text view should display the correct text")
    }
    
    func test_progressView_VerifyDefaultInitialization_defaultTintColorOfTheProgressIndicatorIsCorrect() throws {
        let sut = makeSUT()
       
        let progressView = try sut
            .inspect()
            .find(viewWithTag: DMProgressViewOwnSettings.progressViewTag)
            .progressView()
        
        XCTAssertEqual(try progressView.tint(),
                       .white,
                       "The ProgressView should have the correct tint color")
    }
    
    // MARK: HELPERs
    
    private func makeSUT(
        withSettings settings: DMLoadingViewSettings = DMLoadingDefaultViewSettings()
    ) -> DMProgressView {
        
        DMProgressView(settings: settings)
    }
}
