//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

final class DMLoadingViewProviderUseCaseTests: XCTestCase {

    func test_defaultImplementation_providesLoadingManagerSettings() {
        let sut = LoadingViewProviderSpy()
        
        let settingsUT = sut.loadingManagerSettings
        XCTAssertEqual(settingsUT.autoHideDelay, .seconds(2))
    }
    
    
    // MARK: - Helpers
}

private final class LoadingViewProviderSpy: DMLoadingViewProvider {
    var id: UUID
    
    init() {
        self.id = UUID()
    }
}
