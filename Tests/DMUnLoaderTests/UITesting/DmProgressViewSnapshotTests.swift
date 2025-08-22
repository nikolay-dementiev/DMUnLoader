//
//  DMUnLoader
//
//  Created by Mykola Dementiev
//

import XCTest
@testable import DMUnLoader
import PreviewSnapshots
import PreviewSnapshotsTesting

@MainActor
final class DmProgressViewSnapshotTests: XCTestCase {
    override func invokeTest() {
        withSnapshotTesting(record: .failed, diffTool: .ksdiff) {
            super.invokeTest()
        }
    }
    
    func test_progressView_VerifyDefaultInitialization() {
        let snapshots = makeSUT(
            withConfiguration: .init(
                name: "DefaultSettings",
                state: DMLoadingDefaultViewSettings()
            )
        )
        
        expect(
            snapshots,
            named: frameworkName,
            record: false
        )
    }
    
    func test_progressView_VerifyCustomSettings() {
        let snapshots = makeSUT(
            withConfiguration: .init(
                name: "CustomSettings",
                state: DMLoadingDefaultViewSettings(
                    loadingTextProperties: LoadingTextProperties(
                        text: "Processing...",
                        alignment: .leading,
                        foregroundColor: .orange,
                        font: .title3
                    ),
                    progressIndicatorProperties: ProgressIndicatorProperties(
                        tintColor: .green
                    )
                )
            )
        )
        
        expect(
            snapshots,
            named: frameworkName,
            record: false
        )
    }
    
    // MARK: HELPERs
    
    func makeSUT<VS: DMLoadingViewSettings>(
        withConfiguration configurations: PreviewSnapshots<VS>.Configuration...
    ) -> PreviewSnapshots<VS> {
        let snapshots = PreviewSnapshots<VS>(
            configurations: configurations,
            configure: { state in
                DMProgressView(settings: state)
                    .addModificationForAlerView()
                    .transaction { transaction in // disabling animation
                        transaction.animation = nil
                    }
                    .padding()
            }
        )
        
        return snapshots
    }
    
    func expect<State>(
        _ snapshot: PreviewSnapshots<State>,
        named name: String? = nil,
        record recording: Bool = false,
        file: StaticString = #filePath,
        testName: String = #function,
        line: UInt = #line
    ) {
        snapshot.assertSnapshots(as: ["iPhone13-Light": .testStrategyiPhone13Light,
                                      "iPhone13-Dark": .testStrategyiPhone13Dark],
                                 named: name,
                                 record: recording,
                                 file: file,
                                 testName: testName,
                                 line: line)
    }
}
