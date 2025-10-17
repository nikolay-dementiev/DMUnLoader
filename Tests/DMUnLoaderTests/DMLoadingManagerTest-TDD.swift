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
    
    @MainActor
    func showLoading<PR>(provider: PR) where PR: DMLoadingViewProviderProtocol {
        loadableState = .loading(
            provider: provider.eraseToAnyViewProvider()
        )
    }
    
    @MainActor
    func showSuccess<PR>(
        _ message: DMLoadableTypeSuccess,
        provider: PR
    ) where PR: DMLoadingViewProviderProtocol {
        
    }
    
    @MainActor
    func showFailure<PR>(
        _ error: any Error,
        provider: PR,
        onRetry: (DMAction)?
    ) where PR: DMLoadingViewProviderProtocol {
        
    }
    
    func hide() {
        
    }
}

@MainActor
final class DMLoadingManagerTestTDD: XCTestCase {
    
    func testDefaultInitialization() {
        let sut = makeSUT()
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
    
    func testVerifyLoadingState() {
        let sut = makeSUT()
        let provider = TestDMLoadingViewProvider()
        
        sut.showLoading(provider: provider)
        
        XCTAssertEqual(
            sut.loadableState,
            .loading(
                provider: provider.eraseToAnyViewProvider()
            ),
            "After calling `showLoading(provider:)`, `loadableState` should be `.loading` with the correct provider"
        )
        
        
    }
    
    // MARK: - Helpers
    private func makeSUT() -> LoadingManagerTDD {
        LoadingManagerTDD()
    }
}

final class TestDMLoadingViewProvider: DMLoadingViewProviderProtocol {
    public var id: UUID = UUID()
}
