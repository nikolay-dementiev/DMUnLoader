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
    
    // MARK: HELPERs
    
    private func makeSUT() -> DMProgressView {
        DMProgressView(settings: DMLoadingDefaultViewSettings())
    }
}
