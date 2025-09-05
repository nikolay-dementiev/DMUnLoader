//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import XCTest
import Combine
@testable import DMUnLoader

final class MockDMLoadingViewProvider: DMLoadingViewProviderProtocol {
    typealias LoadingViewType = Text
    typealias ErrorViewType = Text
    typealias SuccessViewType = Text
    
    public var id: UUID = UUID()
    
    @MainActor
    func getLoadingView() -> LoadingViewType {
        Text("Mock Loading View")
    }

    @MainActor
    func getErrorView(error: Error, onRetry: DMAction?, onClose: DMAction) -> ErrorViewType {
        Text("Mock Error View")
    }

    @MainActor
    func getSuccessView(object: DMLoadableTypeSuccess) -> SuccessViewType {
        Text("Mock Success View")
    }

    var loadingManagerSettings: DMLoadingManagerSettings {
        MockDMLoadingManagerSettings(autoHideDelay: .seconds(2))
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
