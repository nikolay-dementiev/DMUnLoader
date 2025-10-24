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
                
                ProgressView()
                    .controlSize(progressIndicatorProperties.size)
                    .progressViewStyle(.circular)
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
    
    // MARK: - Helpers
    
    @MainActor
    private func makeSUT() -> DMProgressViewTDD {
        DMProgressViewTDD(settings: MockDMProgressViewSettings())
    }
}
