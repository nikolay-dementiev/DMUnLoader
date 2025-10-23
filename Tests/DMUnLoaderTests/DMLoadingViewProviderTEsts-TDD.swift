//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader
import SwiftUI

protocol DMLoadingViewProvider: ObservableObject, Hashable, Identifiable {
    associatedtype LoadingViewType: View
    associatedtype ErrorViewType: View
    associatedtype SuccessViewType: View

    var id: UUID { get }
    
    func getLoadingView() -> LoadingViewType
    func getErrorView(error: Error, onRetry: DMAction?, onClose: DMAction) -> ErrorViewType
    func getSuccessView(object: DMLoadableTypeSuccess) -> SuccessViewType

    var loadingManagerSettings: DMLoadingManagerSettings { get }
    var loadingViewSettings: DMLoadingViewSettings { get }
    var errorViewSettings: DMErrorViewSettings { get }
    var successViewSettings: DMSuccessViewSettings { get }
}

final class DMLoadingViewProviderTEsts_TDD: XCTestCase {

//    func testExample() {
//        XCTFail()
//    }
}
