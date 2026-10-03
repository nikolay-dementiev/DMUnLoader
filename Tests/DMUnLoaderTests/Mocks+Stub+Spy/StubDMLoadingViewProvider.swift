//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import SwiftUI
import XCTest
import Combine
@testable import DMUnLoader

final class StubDMLoadingViewProvider: @MainActor DMLoadingViewProvider {
    typealias LoadingViewType = StubDMLoadingViewResult<Text>
    typealias ErrorViewType = StubDMLoadingViewResult<Text>
    typealias SuccessViewType = StubDMLoadingViewResult<Text>
    
    @MainActor
    func getLoadingView() -> LoadingViewType {
        StubDMLoadingViewResult {
            Text("Stub Loading View")
        }
    }
    
    @MainActor
    func getErrorView(error: any Error, onRetry: (any DMAction)?, onClose: any DMAction) -> ErrorViewType {
        StubDMLoadingViewResult {
            Text("Stub Error View")
        }
    }
    
    @MainActor
    func getSuccessView(object: any DMLoadableTypeSuccess) -> SuccessViewType {
        StubDMLoadingViewResult {
            Text("Stub Success View")
        }
    }
    
    var loadingManagerSettings: any DMLoadingManagerSettings {
        StubDMLoadingManagerSettings(autoHideDelay: .seconds(2))
    }
    
    var loadingViewSettings: any DMProgressViewSettings {
        StubDMProgressViewSettings()
    }
    
    var errorViewSettings: any DMErrorViewSettings {
        StubDMErrorViewSettings()
    }
    
    var successViewSettings: any DMSuccessViewSettings {
        StubDMSuccessViewSettings()
    }
    
    struct StubDMLoadingViewResult<Content: View>: View {
        @ViewBuilder let content: () -> Content
        
        init(_ content: @escaping () -> Content) {
            self.content = content
        }
        
        var body: some View {
            content()
                .background(Color.orange.opacity(0.3))
                .border(Color.orange, width: 1)
        }
    }
}
