//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
import DMUnLoader
import SwiftUICore

final class DMLoadingViewProviderUseCaseTests: XCTestCase {

    func test_defaultImplementation_providesLoadingManagerSettings() {
        let sut = makeSUT()
        
        let settingsUT = sut.loadingManagerSettings
        XCTAssertEqual(settingsUT.autoHideDelay, .seconds(2))
    }
    
    func test_defaultImplementation_providesLoadingViewSettings() {
        let sut = makeSUT()
        
        let settingsUT = sut.loadingViewSettings
        XCTAssertEqual(
            settingsUT.frameGeometrySize,
            CGSize(width: 300, height: 300)
        )
        XCTAssertEqual(
            settingsUT.loadingContainerForegroundColor,
            .primary
        )
        XCTAssertEqual(
            settingsUT.progressIndicatorProperties,
            ProgressIndicatorProperties(
                size: .large,
                tintColor: .white
            )
        )
        XCTAssertEqual(
            settingsUT.loadingTextProperties,
            LoadingTextProperties(
                text: LoadingTextProperties.defaultText,
                alignment: .center,
                foregroundColor: .white,
                font: .body,
                lineLimit: 3,
                linePadding: EdgeInsets(
                    top: 0,
                    leading: 10,
                    bottom: 0,
                    trailing: 10
                )
            )
        )
    }
    
    // MARK: - Helpers
    private func makeSUT() -> LoadingViewProviderSpy {
        LoadingViewProviderSpy()
    }
}

extension ProgressIndicatorProperties: Equatable {
    public static func == (lhs: ProgressIndicatorProperties, rhs: ProgressIndicatorProperties) -> Bool {
        lhs.size == rhs.size && lhs.tintColor == rhs.tintColor
    }
}

extension LoadingTextProperties: Equatable {
    public static func == (lhs: LoadingTextProperties, rhs: LoadingTextProperties) -> Bool {
        lhs.text == rhs.text &&
        lhs.alignment == rhs.alignment &&
        lhs.foregroundColor == rhs.foregroundColor &&
        lhs.font == rhs.font &&
        lhs.lineLimit == rhs.lineLimit &&
        lhs.linePadding == rhs.linePadding
    }
}

private final class LoadingViewProviderSpy: DMLoadingViewProvider {
    var id: UUID
    
    init() {
        self.id = UUID()
    }
}
