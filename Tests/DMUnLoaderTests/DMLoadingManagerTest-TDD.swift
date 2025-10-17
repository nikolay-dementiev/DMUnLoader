//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader

struct LoadingManagerDefaultSettingsTDD: DMLoadingManagerSettings {
    let autoHideDelay: Duration
    
    init(autoHideDelay: Duration = .seconds(2)) {
        self.autoHideDelay = autoHideDelay
    }
}

final class LoadingManagerTDD: DMLoadingManagerProtocol {
    var loadableState: DMLoadableType
    
    var settings: DMLoadingManagerSettings
    
    init(
        loadableState: DMLoadableType,
        settings: DMLoadingManagerSettings
    ) {
        self.loadableState = loadableState
        self.settings = settings
    }
    
    convenience init() {
        self.init(
            loadableState: .none,
            settings: LoadingManagerDefaultSettingsTDD()
        )
    }
    
    func showLoading<PR>(provider: PR) where PR: DMLoadingViewProviderProtocol {
        
    }
    
    func showSuccess<PR>(
        _ message: DMLoadableTypeSuccess,
        provider: PR
    ) where PR: DMLoadingViewProviderProtocol {
        
    }
    
    func showFailure<PR>(
        _ error: any Error,
        provider: PR,
        onRetry: (DMAction)?
    ) where PR: DMLoadingViewProviderProtocol {
        
    }
    
    func hide() {
        
    }
}

final class DMLoadingManagerTestTDD: XCTestCase {

    @MainActor
    func testDefaultInitialization() throws {
        let sut = LoadingManagerTDD()
        XCTAssertTrue(
            (sut as AnyObject) is (any DMLoadingManagerProtocol),
            "LoadingManager should conform to DMLoadingManagerProtocol"
        )
        
        XCTAssertEqual(
            sut.loadableState,
            .none,
            "Default loadableState should be `.none`"
        )
        
        XCTAssertTrue(
            sut.settings is LoadingManagerDefaultSettingsTDD,
            "Default settings should be an instance of LoadingManagerDefaultSettingsTDD"
        )
    }
}
